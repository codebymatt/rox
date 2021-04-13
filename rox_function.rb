# frozen_string_literal: true

require './environment'
require './return_error'

# Handle Rox function implementation.
class RoxFunction
  attr_reader :declaration, :closure, :is_initializer

  def initialize(declaration, closure, is_initializer)
    @closure = closure
    @declaration = declaration
    @is_initializer = is_initializer
  end

  def bind(instance)
    environment = Environment.new(@closure)
    environment.define('this', instance)
    RoxFunction.new(@declaration, environment, @is_initializer)
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
      return @closure.get_at(0, 'this') if @is_initializer

      return e.value
    end

    return @closure.get_at(0, 'this') if @is_initializer

    nil
  end

  def arity
    @declaration.params.length
  end

  def to_string
    "<fn #{declaration.name.lexeme}>"
  end
end
