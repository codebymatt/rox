# frozen_string_literal: true

# Holds all available token types for scanning.
# Not used in code, but useful as reference for symbols.
# Maybe should be in Markdown as documentation?
module TokenType
  def types
    [
      # Single character tokens.
      :LEFT_PAREN, :RIGHT_PAREN, :LEFT_BRACE, :RIGHT_BRACE,
      :COMMA, :DOT, :MINUS, :PLUS, :SEMICOLON, :SLASH, :STAR,

      # One/two character tokens.
      :BANG, :BANG_EQUAL, :EQUAL, :EQUAL_EQUAL,
      :GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL,

      # Literals.
      :IDENTIFIER, :STRING, :NUMBER,

      # Keywords.
      :AND, :CLASS, :ELSE, :FALSE, :FUN, :FOR, :IF, :NIL, :OR,
      :PRINT, :RETURN, :SUPER, :THIS, :TRUE, :VAR, :WHILE,

      :EOF
    ]
  end
end
