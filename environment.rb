# frozen_string_literal: true

# Keeps track of all variables declared.
class Environment
  attr_accessor :values, :enclosing

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

  def get_at(distance, name)
    ancestor(distance).values[name]
  end

  def assign_at(distance, name, value)
    ancestor(distance).values[name.lexeme] = value
  end

  def ancestor(distance)
    environment = self
    distance.times { |_n| environment = environment.enclosing }

    environment
  end
end
