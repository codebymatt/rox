# frozen_string_literal: true

# Parses AST by recursive descent.
class Parser
  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
    @current = 0
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
      expr = Binary(expr, operator, right)
    end
  end

  def match(*types)
    types.each do |type|
      if next_token_is(type)
        advance
        true
      end
    end

    false
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
    peek_next_token.type == EOF
  end

  def peek_next_token
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end
end
