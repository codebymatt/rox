# frozen_string_literal: true

# Implements scanning for the interpreter.
class Scanner
  attr_accessor :source
  attr_accessor :tokens
  attr_accessor :start
  attr_accessor :current
  attr_accessor :line_num

  def new(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line_num = 1
  end

  def scan_tokens
    until at_end
      start = current
      scan_token
    end

    tokens << Token.new(EOF, '', null, line_num)
  end

  def scan_token
    c = advance_current

    case c
    when '('
      add_single_token(:LEFT_PAREN)
    when ')'
      add_single_token(:RIGHT_PAREN)
    when '{'
      add_single_token(:LEFT_BRACE)
    when '}'
      add_single_token(:RIGHT_BRACE)
    when ','
      add_single_token(:COMMA)
    when '.'
      add_single_token(:DOT)
    when '-'
      add_single_token(:MINUS)
    when '+'
      add_single_token(:PLUS)
    when ';'
      add_single_token(:SEMICOLON)
    when '*'
      add_single_token(:STAR)
    end
  end

  private

  def at_end
    current >= source.length
  end

  def advance_current
    current += 1
    source[current - 1]
  end

  def add_single_token(token_type)
    add_token(token_type, null)
  end

  def add_token(token_type, object_literal)
    text = source[start...current]
    tokens << Token.new(token_type, text, object_literal, line_num)
  end
end
