# frozen_string_literal: true

# Keeps track of all variables declared.
class Environment
  def initialize
    @values = {}
  end

  def get(name)
    return @values[name.lexeme] unless @values[name.lexeme].nil?

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'")
  end

  def define(name, value)
    @values[name] = value
  end
end
