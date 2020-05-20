# frozen_string_literal: true

require './ast_printer.rb'
require './interpreter.rb'
require './parser.rb'
require './scanner.rb'

# Entry point for the Rox interpreter.
class Rox
  class << self
    def error(line, message)
      report(line, '', message)
    end

    def parse_error(token, message)
      if token.type == :EOF
        report(token.line_num, ' at end', message)
      else
        interpolated_string = " at '#{token.lexeme}'"
        report(token.line_num, interpolated_string, message)
      end
    end

    def runtime_error(error)
      puts "#{error.message}\n[line #{error.token.line}]"
      @had_runtime_error = true
    end

    def report(line, where, message)
      puts "[line #{line}] Error#{where}: #{message}"
      @had_error = true
    end
  end

  def initialize(arguments)
    @had_error = false
    @had_runtime_error = true
    @interpreter = Interpreter.new
    main(arguments)
  end

  private

  def main(args)
    if args.length > 1
      puts 'Usage: ./rox [script]'
      exit(64)
    elsif args.length == 1
      run_file(args[0])
    else
      run_prompt
    end
  end

  def run_file(path)
    file_contents = File.read(path)

    run(file_contents)
    exit(65) if @had_error
    exit(70) if @had_runtime_error
  end

  def run_prompt
    loop do
      print '> '
      STDOUT.flush

      run(gets)
      @had_error = false
    end
  end

  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens
    parser = Parser.new(tokens)
    expression = parser.parse

    return if @had_error

    @interpreter.interpret(expression)
  end
end
