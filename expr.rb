# frozen_string_literal: true

class Expr
end

# Responsible for Binary expression
class Binary < Expr
  attr_accessor :left, :operator, :right

  def initialize(left, operator, right)
    @left = left
    @operator = operator
    @right = right
  end

  def accept(visitor)
    visitor.visit_binary_expr(self)
  end
end

# Responsible for Grouping expression
class Grouping < Expr
  attr_accessor :expression

  def initialize(expression)
    @expression = expression
  end

  def accept(visitor)
    visitor.visit_grouping_expr(self)
  end
end

# Responsible for Literal expression
class Literal < Expr
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def accept(visitor)
    visitor.visit_literal_expr(self)
  end
end

# Responsible for Unary expression
class Unary < Expr
  attr_accessor :operator, :right

  def initialize(operator, right)
    @operator = operator
    @right = right
  end

  def accept(visitor)
    visitor.visit_unary_expr(self)
  end
end

# Responsible for Variable expression
class Variable < Expr
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def accept(visitor)
    visitor.visit_variable_expr(self)
  end
end
