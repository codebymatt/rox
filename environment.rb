# frozen_string_literal: true

# Keeps track of all variables declared.
class Environment
  def initialize(enclosing = nil)
    @values = {}
    @enclosing = enclosing
  end

  def get(name)
    return @values[name.lexeme] unless @values[name.lexeme].nil?
    return @enclosing.get(name) unless @enclosing.nil?

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'")
  end

  def assign(name, value)
    if @values.include? name.lexeme
      @values[name.lexeme] = value
      return
    end

    unless @enclosing.nil?
      @enclosing.assign(name, value)
      return
    end

    raise RuntimeError.new(name, "Undefined variable '#{name.lexeme}'.")
  end

  def define(name, value)
    @values[name] = value
  end
end
