# frozen_string_literal: true

class Stmt
end

# Responsible for Block expression
class Block < Stmt
  attr_accessor :statements

  def initialize(statements)
    @statements = statements
  end

  def accept(visitor)
    visitor.visit_block_stmt(self)
  end
end

# Responsible for Klass expression
class Klass < Stmt
  attr_accessor :name, :superclass, :methods

  def initialize(name, superclass, methods)
    @name = name
    @superclass = superclass
    @methods = methods
  end

  def accept(visitor)
    visitor.visit_klass_stmt(self)
  end
end

# Responsible for Expression expression
class Expression < Stmt
  attr_accessor :expression

  def initialize(expression)
    @expression = expression
  end

  def accept(visitor)
    visitor.visit_expression_stmt(self)
  end
end

# Responsible for If expression
class If < Stmt
  attr_accessor :condition, :then_branch, :else_branch

  def initialize(condition, then_branch, else_branch)
    @condition = condition
    @then_branch = then_branch
    @else_branch = else_branch
  end

  def accept(visitor)
    visitor.visit_if_stmt(self)
  end
end

# Responsible for Function expression
class Function < Stmt
  attr_accessor :name, :params, :body

  def initialize(name, params, body)
    @name = name
    @params = params
    @body = body
  end

  def accept(visitor)
    visitor.visit_function_stmt(self)
  end
end

# Responsible for Print expression
class Print < Stmt
  attr_accessor :expression

  def initialize(expression)
    @expression = expression
  end

  def accept(visitor)
    visitor.visit_print_stmt(self)
  end
end

# Responsible for Return expression
class Return < Stmt
  attr_accessor :keyword, :value

  def initialize(keyword, value)
    @keyword = keyword
    @value = value
  end

  def accept(visitor)
    visitor.visit_return_stmt(self)
  end
end

# Responsible for Var expression
class Var < Stmt
  attr_accessor :name, :initializer

  def initialize(name, initializer)
    @name = name
    @initializer = initializer
  end

  def accept(visitor)
    visitor.visit_var_stmt(self)
  end
end

# Responsible for While expression
class While < Stmt
  attr_accessor :condition, :body

  def initialize(condition, body)
    @condition = condition
    @body = body
  end

  def accept(visitor)
    visitor.visit_while_stmt(self)
  end
end

