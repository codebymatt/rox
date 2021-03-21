# frozen_string_literal: true

require './rox_instance'

# Holds the implementation for Rox's classes.
class RoxClass
  attr_reader :name, :methods

  def initialize(name, methods = {})
    @name = name
    @methods = methods
  end

  def find_method(name)
    @methods[name]
  end

  def to_s
    @name
  end

  def to_string
    to_s
  end

  def call(_interpreter, _arguments)
    RoxInstance.new(self)
  end

  def arity
    0
  end
end
