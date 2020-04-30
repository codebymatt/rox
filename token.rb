# frozen_string_literal: true

# Handles tokens for scanning.
class Token
  def initialize(token_type, lexeme, object_literal, line_num)
    @token_type = token_type
    @lexeme = lexeme
    @object_literal = object_literal
    @line_num = line_num
  end

  def to_string
    "#{@token_type} #{@lexeme} #{@object_literal}"
  end
end
