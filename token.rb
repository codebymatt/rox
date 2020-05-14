# frozen_string_literal: true

# Handles tokens for scanning.
class Token
  attr_reader :token_type, :lexeme, :object_literal, :line_num

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
