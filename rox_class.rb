# frozen_string_literal: true

# Holds the implementation for Rox's classes.
class RoxClass
  attr_accessor :name

  def initialize(name, methods = [])
    @name = name
  end

  def to_s
    @name
  end
end
