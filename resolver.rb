# frozen_string_literal: true

# Handles variable resolution in between parsing and interpreting
class Resolver
  attr_accessor :interpreter, :scopes

  def initialize(interpreter)
    @interpreter = interpreter
    @scopes = []
  end

  def visit_block_stmt(stmt)
    begin_scope
    resolve_statments(stmt.statements)
    end_scope

    nil
  end

  private

  def begin_scope
    scopes.push({})
  end

  def resolve_statments(statements)
    statements.each { resolve(statement) }
  end

  def resolve(stmt)
    stmt.accept(self)
  end

  def end_scope
    scopes.pop
  end
end
