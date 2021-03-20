# frozen_string_literal: true

# Holds the implementation for Rox Class instances.
class RoxInstance
  def initialize(klass)
    @klass = klass
  end

  def to_s
    "#{@klass.name} instance"
  end

  def to_string
    to_s
  end
end
