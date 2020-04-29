# frozen_string_literal: true

# Implements scanning for the interpreter.
class Scanner
  attr_accessor :source
  attr_accessor :tokens
  attr_accessor :start
  attr_accessor :current
  attr_accessor :line_num
  attr_accessor :keywords

  KEYWORDs = [
    'and', 'class', 'else', 'false', 'for', 'fun', 'if', 'nil',
    'or', 'print', 'return', 'super', 'this', 'true', 'var', 'while'
  ]

  def new(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line_num = 1
    @keywords = KEYWORDS.map { |key| [key, key.upcase.to_sym] }.to_h
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
    when '!'
      add_single_token(next_char_is('=') ? :BANG_EQUAL : :BANG)
    when '='
      add_single_token(next_char_is('=') ? :EQUAL_EQUAL : :EQUAL)
    when '<'
      add_single_token(next_char_is('=') ? :LESS_EQUAL : :EQUAL)
    when '>'
      add_single_token(next_char_is('=') ? :GREATER_EQUAL : :EQUAL)
    when '/'
      if next_char_is('/')
        advance_current while peek != '\n' && !at_end
      else
        add_single_token(:SLASH)
      end
    when ' ', '\r', '\t'
      nil
    when '\n'
      line_num += 1
    when '"'
      handle_string
    else
      if digit?(c)
        handle_number
      elsif alpha?(c)
        handle_identifier
      else
        Rox.error(line_num, 'Unexpected character.')
      end
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

  def next_char_is(expected)
    return false if at_end || source[current] != expected

    current += 1
    true
  end

  def peek
    return '\0' if at_end

    source[current]
  end

  def digit?(char)
    char =~ /[0-9]/
  end

  def handle_string
    proceed_until_quote_ends

    if at_end
      Rox.error(line_num, 'Unterminated string.')
      return
    end

    advance_current

    string_value = source[(start + 1)..current]
    add_token(:STRING, string_value)
  end

  def proceed_until_quote_ends
    while peek != '"' && !at_end
      line_num += 1 if peek == '\n'
      advance_current
    end
  end

  def handle_number
    advance_current while digit?(peek)

    capture_decimal_value_if_present
    add_token(:NUMBER, Float.new(source[start...current]))
  end

  def capture_decimal_value_if_present
    return unless peek == '.' && digit?(peekNext)

    advance_current
    advance_current while digit?(peek)
  end

  def peek_next
    return '\0' if current + 1 > source.length

    source[current + 1]
  end

  def handle_identifier
    advance_current while alphanumeric?(peek)

    text = source[start...current]
    type = keywords[text].nil? ? :IDENTIFIER : keywords[text]

    add_single_token(type)
  end

  def alpha?(char)
    (char >= 'a' && c <= 'z') ||
      (char >= 'A' && c <= 'Z') ||
      c == '_'
  end

  def alphanumeric?(char)
    alpha?(char) || digit?(char)
  end
end
