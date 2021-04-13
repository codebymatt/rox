# frozen_string_literal: true

require './environment'
require './return_error'
require './rox'
require './rox_class'
require './rox_function'
require './runtime_error'

# Interprets the value of syntax leaf nodes.
class Interpreter
  attr_reader :globals

  def initialize
    @locals = {}
    @globals = Environment.new
    @environment = globals

    @globals.define(
      'clock',
      Class.new do
        def self.arity
          0
        end

        def self.call
          Time.now.utc.to_f
        end

        def self.to_string
          '<native fn>'
        end
      end
    )
  end

  def interpret(statements)
    statements.each { |stmt| execute(stmt) }
  rescue RuntimeError => e
    Rox.runtime_error(e)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_unary_expr(expr)
    right = evalue(expr.right)

    case expr.operator.type
    when :MINUS
      check_number_operand(expr.operator, right)
      return -right.to_f
    when :BANG
      return !truthy?(right)
    end

    nil
  end

  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when :GREATER
      check_number_operands(expr.operator, left, right)
      left.to_f > right.to_f
    when :GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      left.to_f >= right.to_f
    when :LESS
      check_number_operands(expr.operator, left, right)
      left.to_f < right.to_f
    when :LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      left.to_f <= right.to_f
    when :MINUS
      check_number_operands(expr.operator, left, right)
      left.to_f - right.to_f
    when :PLUS
      return left.to_f + right.to_f if left.is_a?(Float) && right.is_a?(Float)
      return left.to_s + right.to_s if left.is_a?(String) && right.is_a?(String)

      raise RuntimeError.new(
        expr.operator,
        'Operands must be two numbers or two strings'
      )
    when :SLASH
      check_number_operands(expr.operator, left, right)
      left.to_f / right
    when :STAR
      check_number_operands(expr.operator, left, right)
      left.to_f * right.to_f
    when :BANG_EQUAL
      !equal?(left, right)
    when :EQUAL_EQUAL
      equal?(left, right)
    end
  end

  def visit_logical_expr(expr)
    left = evaluate(expr.left)

    if expr.operator.type == :OR
      return left if truthy?(left)
    else
      return left unless truthy?(left)
    end

    evaluate(expr.right)
  end

  def visit_set_expr(expr)
    object = evaluate(expr.object)
    raise RuntimeError.new(expr.name, 'Only instances have fields.') unless object.is_a? RoxInstance

    value = evaluate(expr.value)
    # object.set(expr, value)
    object.set(expr.name, value)

    value
  end

  def visit_super_expr(expr)
    distance = @locals[expr]
    superclass = @environment.get_at(distance, 'super')
    object = @environment.get_at(distance - 1, 'this')

    method = superclass.find_method(expr.method.lexeme)

    if method.nil?
      raise RuntimeError.new(expr.method, "Undefined property '#{expr.method.lexeme}'.")
    end

    method.bind(object)
  end

  def visit_this_expr(expr)
    look_up_variable(expr, expr.keyword)
  end

  def visit_call_expr(expr)
    callee = evaluate(expr.callee)

    arguments = expr.arguments.map { |arg| evaluate(arg) }

    unless callee.respond_to?(:call)
      raise RuntimeError.new(expr.paren, 'Can only call functions and classes.')
    end

    function = callee

    if arguments.length != function.arity
      raise RuntimeError.new(
        expr.paren,
        "Expected #{function.arity} arguments but got #{arguments.length}."
      )
    end

    function.call(self, arguments)
  end

  def visit_get_expr(expr)
    object = evaluate(expr.object)
    return object.get(expr.name) if object.is_a? RoxInstance

    raise RuntimeError.new(expr.name, 'Only instances have properties.')
  end

  def visit_expression_stmt(stmt)
    evaluate(stmt.expression)
    nil
  end

  def visit_function_stmt(stmt)
    function = RoxFunction.new(stmt, @environment, false)
    @environment.define(stmt.name.lexeme, function)
    nil
  end

  def visit_if_stmt(stmt)
    if truthy?(evaluate(stmt.condition))
      execute(stmt.then_branch)
    elsif !stmt.else_branch.nil?
      execute(stmt.else_branch)
    end
  end

  def visit_print_stmt(stmt)
    value = evaluate(stmt.expression)
    puts stringify(value)
    nil
  end

  def visit_return_stmt(stmt)
    value = stmt.value.nil? ? nil : evaluate(stmt.value)

    raise ReturnError.new(value, nil)
  end

  def visit_var_stmt(stmt)
    value = stmt.initializer.nil? ? nil : evaluate(stmt.initializer)

    @environment.define(stmt.name.lexeme, value)
  end

  def visit_while_stmt(stmt)
    execute(stmt.body) while truthy?(evaluate(stmt.condition))
  end

  def visit_block_stmt(stmt)
    execute_block(stmt.statements, Environment.new(@environment))
    nil
  end

  def visit_klass_stmt(stmt)
    superclass = nil

    unless stmt.superclass.nil?
      superclass = evaluate(stmt.superclass)

      unless superclass.is_a? RoxClass
        raise RuntimeError.new(stmt.superclass.name, 'Superclass must be a class.')
      end
    end

    @environment.define(stmt.name.lexeme, nil)

    unless stmt.superclass.nil?
      @environment = Environment.new(@environment)
      @environment.define('super', superclass)
    end

    methods = stmt.methods.map do |method|
      function = RoxFunction.new(method, @environment, method.name.lexeme == 'init')
      [method.name.lexeme, function]
    end.to_h

    klass = RoxClass.new(stmt.name.lexeme, superclass, methods)

    @environment = @environment.enclosing unless stmt.superclass.nil?
    @environment.assign(stmt.name, klass)
  end

  def visit_assign_expr(expr)
    value = evaluate(expr.value)
    distance = @locals[expr]

    if !distance.nil?
      @environment.assign_at(distance, expr.name, value)
    else
      @globals.assign(expr.name, value)
    end

    value
  end

  def visit_variable_expr(expr)
    look_up_variable(expr, expr.name)
  end

  def look_up_variable(expr, name)
    distance = @locals[expr]
    return @environment.get_at(distance, name.lexeme) unless distance.nil?

    @globals.get(name)
  end

  def execute_block(statements, environment)
    previous_environment = @environment
    @environment = environment
    statements.each { |statement| execute(statement) }
  ensure
    @environment = previous_environment
  end

  def resolve(expr, depth)
    @locals[expr] = depth
  end

  private

  def evaluate(expr)
    expr.accept(self)
  end

  def execute(stmt)
    stmt.accept(self)
  end

  def stringify(object)
    return 'nil' if object.nil?

    if object.is_a? Float
      text = object.to_s
      text = text.chomp('.0') if text.end_with?('.0')

      return text
    end

    object.to_s
  end

  def truthy?(object)
    return false if object.nil?
    return object if [true, false].include? object

    true
  end

  def equal?(left, right)
    return true if left.nil? && right.nil?
    return false if left.nil?

    a == b
  end

  def check_number_operand(operator, operand)
    return if operand.is_a? Float

    raise RuntimeError.new(operator, 'Operand must be a number.')
  end

  def check_number_operands(operator, left, right)
    return if left.is_a?(Float) && right.is_a?(Float)

    raise RuntimeError.new(operator, 'Operands must be numbers.')
  end
end
