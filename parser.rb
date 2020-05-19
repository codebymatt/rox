# frozen_string_literal: true

require './expr.rb'
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
    expression
  rescue ParseError
    nil
  end

  private

  def expression
    equality
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
      return if previous.type == SEMICOLON
      return if STATEMENT_STARTING_KEYWORDS.include?(peek_next_token.type)
    end

    advance
  end
end
