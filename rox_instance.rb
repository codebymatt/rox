# frozen_string_literal: true

# Holds the implementation for Rox Class instances.
class RoxInstance
  def initialize(klass)
    @klass = klass
    @fields = {}
  end

  def get(name)
    return @fields[name.lexeme] if @fields.keys.include?(name.lexeme)

    method = @klass.find_method(name.lexeme)
    return method unless method.nil?

    raise RuntimeError.new(name, "Undefined property #{name.lexeme}.")
  end

  def set(name, value)
    @fields[name] = value
  end

  def to_s
    "#{@klass.name} instance"
  end

  def to_string
    to_s
  end
end
