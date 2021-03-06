# frozen_string_literal: true

require './expr'
require './stmt'
require './rox'

# Creates AST by recursive descent.
class Parser
  class ParseError < StandardError; end

  STATEMENT_STARTING_KEYWORDS = %i[
    CLASS FUN VAR FOR IF WHILE PRINT RETURN
  ].freeze

  attr_reader :tokens

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    statements = []

    statements << declaration until at_end

    statements
  end

  private

  def declaration
    return class_declaration if match(:CLASS)
    return function('function') if match(:FUN)
    return var_declaration if match(:VAR)

    statement
  rescue ParseError
    synchronize
    nil
  end

  def class_declaration
    name = consume(:IDENTIFIER, 'Expect class name.')

    superclass = nil
    if match(:LESS)
      consume(:IDENTIFIER, 'Expect superclass name.')
      superclass = Variable.new(previous)
    end

    consume(:LEFT_BRACE, "Expect '{' before class body.")

    methods = []
    methods << function('method') while !next_token_is(:RIGHT_BRACE) && !at_end

    consume(:RIGHT_BRACE, "Expect '}' after class body.")
    Klass.new(name, superclass, methods)
  end

  def statement
    return for_statement if match(:FOR)
    return if_statement if match(:IF)
    return print_statement if match(:PRINT)
    return return_statement if match(:RETURN)
    return while_statement if match(:WHILE)
    return Block.new(block) if match(:LEFT_BRACE)

    expression_statement
  end

  def for_statement
    consume(:LEFT_PAREN, "Expect '(' after for.")

    initializer = if match(:SEMICOLON)
                    nil
                  elsif match(:VAR)
                    var_declaration
                  else
                    expression_statement
                  end

    condition = next_token_is(:SEMICOLON) ? nil : expression
    consume(:SEMICOLON, "Expect ';' after loop condition.")

    increment = next_token_is(:RIGHT_PAREN) ? nil : expression
    consume(:RIGHT_PAREN, "Expect ')' after for clauses.")

    body = statement
    body = Block.new([body, Expression.new(increment)]) unless increment.nil?
    condition = Literal.new(true) if condition.nil?

    body = While.new(condition, body)
    body = Block.new([initializer, body]) unless initializer.nil?
    body
  end

  def if_statement
    consume(:LEFT_PAREN, "Expect '(' after 'if'.")
    condition = expression
    consume(:RIGHT_PAREN, "Expect ')' after if condition.")

    then_branch = statement
    else_branch = match(:ELSE) ? statement : nil
    If.new(condition, then_branch, else_branch)
  end

  def print_statement
    value = expression
    consume(:SEMICOLON, "Expect ';' after value.")
    Print.new(value)
  end

  def return_statement
    keyword = previous
    value = match(:SEMICOLON) ? nil : expression

    consume(:SEMICOLON, "Expect ';' after value.")
    Return.new(keyword, value)
  end

  def while_statement
    consume(:LEFT_PAREN, "Expect '(' after 'while'.")
    condition = expression
    consume(:RIGHT_PAREN, "Expect ')' after condition.")
    body = statement

    While.new(condition, body)
  end

  def var_declaration
    name = consume(:IDENTIFIER, 'Expect variable name.')
    initializer = match(:EQUAL) ? expression : nil

    consume(:SEMICOLON, "Expect ';' after variable declaration.")
    Var.new(name, initializer)
  end

  def expression_statement
    expr = expression
    consume(:SEMICOLON, "Expect ';' after value.")
    Expression.new(expr)
  end

  def function(kind)
    name = consume(:IDENTIFIER, "Expect #{kind} name.")
    consume(:LEFT_PAREN, "Expect '(' after #{kind} name.")
    parameters = []

    unless next_token_is(:RIGHT_PAREN)
      loop do
        if parameters.length >= 255
          error_with(peek_next_token, 'Cannot have more than 255 parameters.')
        end

        parameters << consume(:IDENTIFIER, 'Expect parameter name.')
        break unless match(:COMMA)
      end
    end

    consume(:RIGHT_PAREN, "Expect ')' after parameters.")
    consume(:LEFT_BRACE, "Expect '{' before #{kind} body.")
    body = block
    Function.new(name, parameters, body)
  end

  def block
    statements = []

    statements << declaration while !next_token_is(:RIGHT_BRACE) && !at_end
    consume(:RIGHT_BRACE, "Expect '}' after block.")
    statements
  end

  def expression
    assignment
  end

  def assignment
    expr = or_expression
    if match(:EQUAL)
      equals = previous
      value = assignment
      case expr
      when Variable
        return Assign.new(expr.name, value)
      when Get
        return Set.new(expr.object, expr.name, value)
      end

      raise error_with(equals, 'Invalid assignment target.')
    end

    expr
  end

  def or_expression
    expr = and_expression

    while match(:OR)
      operator = previous
      right = and_expression
      expr = Logical.new(expr, operator, right)
    end

    expr
  end

  def and_expression
    expr = equality

    while match(:AND)
      operator = previous
      right = equality
      expr = Logical.new(expr, operator, right)
    end

    expr
  end

  def equality
    expr = comparison

    while match(:BANG_EQUAL, :EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def comparison
    expr = addition

    while match(:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL)
      operator = previous
      right = addition
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def addition
    expr = multiplication

    while match(:MINUS, :PLUS)
      operator = previous
      right = multiplication
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def multiplication
    expr = unary

    while match(:SLASH, :STAR)
      operator = previous
      right = multiplication
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def unary
    if match(:BANG, :MINUS)
      operator = previous
      right = unary
      return Unary.new(operator, right)
    end

    call
  end

  def call
    expr = primary

    loop do
      if match(:LEFT_PAREN)
        expr = finish_call(expr)
      elsif match(:DOT)
        name = consume(:IDENTIFIER, "Expect property name after '.'.")
        expr = Get.new(expr, name)
      else
        break
      end
    end

    expr
  end

  def finish_call(callee)
    arguments = []
    unless next_token_is(:RIGHT_PAREN)
      loop do
        if arguments.length > 255
          error_with(peek_next_token, 'Cannot have more than 255 arguments')
        end

        arguments << expression
        break unless match(:COMMA)
      end
    end

    paren_location = consume(:RIGHT_PAREN, "Expect ')' after arguments")

    Call.new(callee, paren_location, arguments)
  end

  def primary
    return Literal.new(false) if match(:FALSE)
    return Literal.new(true) if match(:TRUE)
    return Literal.new(nil) if match(:NIL)
    return Literal.new(previous.literal) if match(:NUMBER, :STRING)

    if match(:SUPER)
      keyword = previous
      consume(:DOT, "Expect '.' after 'super'.")

      method = consume(:IDENTIFIER, 'Expect superclass method name.')
      return Super.new(keyword, method)
    end

    return This.new(previous) if match(:THIS)
    return Variable.new(previous) if match(:IDENTIFIER)

    if match(:LEFT_PAREN)
      expr = expression
      consume(:RIGHT_PAREN, "Expect ')' after expression.")
      return Grouping.new(expr)
    end

    raise error_with(peek_next_token, 'Expect expression.')
  end

  def match(*types)
    types.each do |type|
      if next_token_is(type)
        advance
        return true
      end
    end

    false
  end

  def consume(type, message)
    return advance if next_token_is(type)

    raise error_with(peek_next_token, message)
  end

  def next_token_is(type)
    return false if at_end

    peek_next_token.type == type
  end

  def advance
    @current += 1 unless at_end
    previous
  end

  def at_end
    peek_next_token.type == :EOF
  end

  def peek_next_token
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def error_with(token, message)
    Rox.parse_error(token, message)
    ParseError.new
  end

  def synchronize
    advance

    until at_end
      return if previous.type == :SEMICOLON
      return if STATEMENT_STARTING_KEYWORDS.include?(peek_next_token.type)
    end

    advance
  end
end
