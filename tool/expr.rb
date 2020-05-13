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
    visitor.visitBinaryExpr(self)
  end
end

# Responsible for Grouping expression
class Grouping < Expr
  attr_accessor :expression

  def initialize(expression)
    @expression = expression
  end

  def accept(visitor)
    visitor.visitGroupingExpr(self)
  end
end

# Responsible for Literal expression
class Literal < Expr
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def accept(visitor)
    visitor.visitLiteralExpr(self)
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
    visitor.visitUnaryExpr(self)
  end
end

