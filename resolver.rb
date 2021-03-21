# frozen_string_literal: true

require './rox'
require './rox_class'

# Handles variable resolution in between parsing and interpreting
class Resolver
  attr_accessor :interpreter, :scopes

  def initialize(interpreter)
    @interpreter = interpreter
    @scopes = []
    @current_function = :NONE
  end

  def resolve_statements(statements)
    statements.each { |statement| resolve(statement) }
  end

  def visit_block_stmt(stmt)
    begin_scope
    resolve_statments(stmt.statements)
    end_scope
  end

  def visit_klass_stmt(stmt)
    declare(stmt.name)
    define(stmt.name)

    stmt.methods.each { |method| resolve_function(method, :METHOD) }

    nil
  end

  def visit_expression_stmt(stmt)
    resolve(stmt.expression)
  end

  def visit_function_stmt(stmt)
    declare(stmt.name)
    define(stmt.name)

    resolve_function(stmt, :FUNCTION)
  end

  def visit_if_stmt(stmt)
    resolve(stmt.condition)
    resolve(stmt.condition)

    resolve(stmt.else_branch) if stmt.else_branch.present?
  end

  def visit_print_stmt(stmt)
    resolve(stmt.expression)
  end

  def visit_return_stmt(stmt)
    if @current_function == :NONE
      Rox.error(stmt.keyword.line_num, "Can't return from top-level code.")
    end

    resolve(stmt.value) unless stmt.value.nil?
  end

  def visit_var_stmt(stmt)
    declare(stmt.name)
    resolve(stmt.initializer) unless stmt.initializer.nil?
    define(stmt.name)
  end

  def visit_while_stmt(stmt)
    resolve(stmt.condition)
    resolve(stmt.body)
  end

  def visit_binary_expr(expr)
    resolve(expr.left)
    resolve(expr.right)
  end

  def visit_call_expr(expr)
    resolve(expr.callee)

    expr.arguments.each { |arg| resolve(arg) }
  end

  def visit_get_expr(expr)
    resolve(expr.object)
    nil
  end

  def visit_grouping_expr(expr)
    resolve(expr.expression)
  end

  def visit_literal_expr(_expr)
    nil
  end

  def visit_logical_expr(expr)
    resolve(expr.left)
    resolve(expr.right)
  end

  def visit_set_expr(expr)
    resolve(expr.value)
    resolve(expr.object)
  end

  def visit_unary_expr(expr)
    resolve(expr.right)
  end

  def visit_variable_expr(expr)
    if !scopes.empty? && !scopes.last[expr.name.lexeme]
      Rox.error(expr.name, "Can't read local initializer in its own initializer.")
    end

    resolve_local(expr, expr.name)
  end

  def visit_assign_expr(expr)
    resolve(expr.value)
    resolve_local(expr, expr.name)
  end

  private

  def begin_scope
    scopes.push({})
  end

  def resolve(target)
    target.accept(self)
  end

  def resolve_function(function, function_type)
    enclosing_function = @current_function
    @current_function = function_type

    begin_scope
    function.params.each do |param|
      declare(param)
      define(param)
    end

    resolve_statements(function.body)
    end_scope
    @current_function = enclosing_function
  end

  def end_scope
    scopes.pop
  end

  def declare(name)
    return if scopes.empty?

    scope = scopes.last

    if scope.key?(name.lexeme)
      Rox.error(name.line_num, 'Variable with this name is already in this scope')
    end

    scope[name.lexeme] = false
  end

  def define(name)
    return if scopes.empty?

    scopes.last[name.lexeme] = true
  end

  def resolve_local(expr, name)
    scopes.reverse.each_with_index do |scope, index|
      unless scope[name.lexeme].nil?
        interpreter.resolve(expr, scopes.length - index - 1)
        break
      end
    end
  end
end
