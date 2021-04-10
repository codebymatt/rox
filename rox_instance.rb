# frozen_string_literal: true

# Holds the implementation for Rox Class instances.
class RoxInstance
  attr_accessor :fields

  def initialize(klass)
    @klass = klass
    @fields = {}
  end

  def get(name)
    return @fields[name.lexeme] if @fields.keys.include?(name.lexeme)

    method = @klass.find_method(name.lexeme)
    return method.bind(self) unless method.nil?

    raise RuntimeError.new(name, "Undefined property #{name.lexeme}.")
  end

  def set(name, value)
    @fields[name.lexeme] = value
  end

  def to_s
    "#{@klass.name} instance"
  end

  def to_string
    to_s
  end
end
