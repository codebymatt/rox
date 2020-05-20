# frozen_string_literal: true

require './rox.rb'
require './runtime_error.rb'

# Interprets the value of syntax leaf nodes.
class Interpreter
  def interpret(expression)
    value = evaluate(expression)
    puts stringify(value)
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

  private

  def evaluate(expr)
    expr.accept(self)
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
