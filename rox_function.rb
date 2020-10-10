# frozen_string_literal: true

require './environment.rb'
require './return_error.rb'

# Handle Rox function implementation.
class RoxFunction
  attr_reader :declaration

  def initialize(declaration)
    @declaration = declaration
  end

  def call(interpreter, arguments)
    environment = Environment.new(interpreter.globals)

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
