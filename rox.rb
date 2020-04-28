#!/usr/bin/env ruby
# frozen_string_literal: true

# Entry point for the Rox interpreter.
class Rox
  attr_writer :had_error

  def main(args)
    if args.length > 1
      puts 'Usage: rox [script]'
      exit(64)
    elsif args.length == 1
      run_file(args[0])
    else
      run_prompt
    end
  end

  def had_error
    @had_error ||= false
  end

  def run_file(path)
    bytes = File.open(path, 'rb')

    # Use 'C' to handle unsigned ints.
    bytes_as_string = bytes.pack('C*').force_encoding('UTF-8')
    run(bytes_as_string)
    exit(65) if had_error
  end

  def run_prompt
    loop do
      puts '> '
      run(gets)
      had_error = false
    end
  end

  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    tokens.each { |token| puts token }
  end

  def error(line, message)
    report(line, '', message)
  end

  def report(line, where, message)
    puts "[line #{line}] Error#{where}: #{message}"
    had_error = true
  end
end
