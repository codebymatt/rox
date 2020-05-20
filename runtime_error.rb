# frozen_string_literal: true

# Implements Rox's runtime error class.
class RuntimeError < StandardError
  attr_reader :token

  def initialize(token, message)
    super(message)
    @token = token
  end
end
