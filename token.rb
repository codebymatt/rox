# frozen_string_literal: true

# Handles tokens for scanning.
class Token
  attr_reader :type, :lexeme, :literal, :line_num

  def initialize(type, lexeme, literal, line_num)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line_num = line_num
  end

  def to_string
    "#{@type} #{@lexeme} #{@literal}"
  end
end
