# frozen_string_literal: true

require './environment'
require './return_error'

# Handle Rox function implementation.
class RoxFunction
  attr_reader :declaration, :closure

  def initialize(declaration, closure)
    @closure = closure
    @declaration = declaration
  end

  def call(interpreter, arguments)
    environment = Environment.new(closure)

    arguments.each_with_index do |_val, index|
      definition = @declaration.params[index].lexeme
      environment.define(definition, arguments[index])
    end

    begin
      interpreter.execute_block(@declaration.body, environment)
    rescue ReturnError => e
      return e.value
    end

    nil
  end

  def arity
    @declaration.params.length
  end

  def to_string
    "<fn #{declaration.name.lexeme}>"
  end
end
