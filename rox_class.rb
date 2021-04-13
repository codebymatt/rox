# frozen_string_literal: true

require './rox_instance'

# Holds the implementation for Rox's classes.
class RoxClass
  attr_reader :name, :methods, :superclass

  def initialize(name, superclass, methods = {})
    @superclass = superclass
    @name = name
    @methods = methods
  end

  def find_method(name)
    return @methods[name] if @methods.keys.include?(name)

    return @superclass.find_method(name) unless @superclass.nil?

    nil
  end

  def to_s
    @name
  end

  def to_string
    to_s
  end

  def call(interpreter, arguments)
    instance = RoxInstance.new(self)
    initializer = find_method('init')

    initializer.bind(instance).call(interpreter, arguments) unless initializer.nil?

    instance
  end

  def arity
    initializer = find_method('init')

    return 0 if initializer.nil?

    initializer.arity
  end
end
