# frozen_string_literal: true

require './expr.rb'
require './stmt.rb'
require './rox.rb'

# Creates AST by recursive descent.
class Parser
  class ParseError < StandardError; end

  STATEMENT_STARTING_KEYWORDS = %i[
    CLASS FUN VAR FOR IF WHILE PRINT RETURN
  ].freeze

  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    statements = []

    statements << declaration until at_end

    statements
  end

  private

  def declaration
    return var_declaration if match(:VAR)

    statement
  rescue ParseError
    synchronize
    nil
  end

  def statement
    return print_statement if match(:PRINT)
    return Block.new(block) if match(:LEFT_BRACE)

    expression_statement
  end

  def print_statement
    value = expression
    consume(:SEMICOLON, "Expect ';' after value.")
    Print.new(value)
  end

  def var_declaration
    name = consume(:IDENTIFIER, 'Expect variable name.')
    initializer = match(:EQUAL) ? expression : nil

    consume(:SEMICOLON, "Expect ';' after variable declaration.")
    Var.new(name, initializer)
  end

  def expression_statement
    expr = expression
    consume(:SEMICOLON, "Expect ';' after value.")
    Expression.new(expr)
  end

  def block
    statements = []

    statements << declaration while !next_token_is(:RIGHT_BRACE) && !at_end
    consume(:RIGHT_BRACE, "Expect '}' fter block.")
    statements
  end

  def expression
    assignment
  end

  def assignment
    expr = equality

    if match(:EQUAL)
      equals = previous
      value = assignment
      return Assign.new(expr.name, value) if expr.is_a? Variable

      raise error_with(equals, 'Invalid assignment target.')
    end

    expr
  end

  def equality
    expr = comparison

    while match(:BANG_EQUAL, :EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def comparison
    expr = addition

    while match(:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL)
      operator = previous
      right = addition
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def addition
    expr = multiplication

    while match(:MINUS, :PLUS)
      operator = previous
      right = multiplication
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def multiplication
    expr = unary

    while match(:SLASH, :STAR)
      operator = previous
      right = multiplication
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def unary
    if match(:BANG, :MINUS)
      operator = previous
      right = unary
      return Unary.new(operator, right)
    end

    primary
  end

  def primary
    return Literal.new(false) if match(:FALSE)
    return Literal.new(true) if match(:TRUE)
    return Literal.new(nil) if match(:NIL)
    return Literal.new(previous.literal) if match(:NUMBER, :STRING)
    return Variable.new(previous) if match(:IDENTIFIER)

    if match(:LEFT_PAREN)
      expr = expression
      consume(:RIGHT_PAREN, "Expect ')' after expression.")
      return Grouping.new(expr)
    end

    raise error_with(peek_next_token, 'Expect expression.')
  end

  def match(*types)
    types.each do |type|
      if next_token_is(type)
        advance
        return true
      end
    end

    false
  end

  def consume(type, message)
    return advance if next_token_is(type)

    raise error_with(peek_next_token, message)
  end

  def next_token_is(type)
    return false if at_end

    peek_next_token.type == type
  end

  def advance
    @current += 1 unless at_end
    previous
  end

  def at_end
    peek_next_token.type == :EOF
  end

  def peek_next_token
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def error_with(token, message)
    Rox.parse_error(token, message)
    ParseError.new
  end

  def synchronize
    advance

    until at_end
      return if previous.type == :SEMICOLON
      return if STATEMENT_STARTING_KEYWORDS.include?(peek_next_token.type)
    end

    advance
  end
end