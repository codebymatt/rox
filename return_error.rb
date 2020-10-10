# frozen_string_literal: true

# Creates exception used by Rox to jump out of function execution flow
class ReturnError < StandardError
  attr_reader :value

  def initialize(value, message = nil)
    super(message)
    @value = value
  end
end
