# frozen_string_literal: true

# Pretty print parsed tree for the basic expression classes.
class AstPrinter
  class << self
    def print(expr)
      expr.accept(self)
    end

    def visit_binary_expr(expr)
      parenthesize(expr.operator.lexeme, expr.left, expr.right)
    end

    def visit_grouping_expr(expr)
      parenthesize('group', expr.expression)
    end

    def visit_literal_expr(expr)
      return 'nil' if expr.value.nil?

      expr.value.to_s
    end

    def visit_unary_expr(expr)
      parenthesize(expr.operator.lexeme, expr.right)
    end

    def parenthesize(name, *exprs)
      string = "(#{name}"
      exprs.each { |expr| string = "#{string} #{expr.accept(self)}" }

      string += ')'
    end
  end
end
