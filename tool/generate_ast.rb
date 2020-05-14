#!/usr/bin/env ruby
# frozen_string_literal: true

# Dynamically generate AST for Rox
class GenerateAST
  def initialize(args)
    @args = args
  end

  def run
    if @args.length != 1
      puts 'Usage: ./generate_ast<output_directory>'
      exit(64)
    end

    output_directory = @args[0]
    define_ast(output_directory, 'Expr', expression_type_array)
  end

  def expression_type_array
    [
      'Binary: left, operator, right',
      'Grouping: expression',
      'Literal: value',
      'Unary: operator, right'
    ]
  end

  def define_ast(output_directory, base_class_name, types)
    @base_class_name = base_class_name
    path = "./#{output_directory}/#{@base_class_name.downcase}.rb"
    @output_file = File.open(path, 'w')

    @output_file.puts('# frozen_string_literal: true')
    @output_file.puts('')

    @output_file.puts("class #{@base_class_name}")
    @output_file.puts('end')
    @output_file.puts('')

    types.each { |type| prepare_and_generate_type(type) }

    @output_file.close
  end

  def prepare_and_generate_type(type)
    sub_class_name = type.split(':')[0].strip
    fields = type.split(':')[1].strip
    define_type(sub_class_name, fields)
  end

  def define_type(sub_class_name, fields)
    write_class_opening(sub_class_name, fields)

    write_initializer(fields)

    write_visitor_pattern(sub_class_name)
    write_class_ending
  end

  def write_class_opening(sub_class_name, fields)
    capitalized_sub_class = sub_class_name.capitalize
    @output_file.puts "# Responsible for #{capitalized_sub_class} expression"
    @output_file.puts("class #{sub_class_name} < #{@base_class_name}")
    @output_file.puts("  attr_accessor #{accessors_from(fields)}")
    @output_file.puts ''
  end

  def write_initializer(fields)
    @output_file.puts("  def initialize(#{fields})")
    fields.split(' ')
          .map { |field| field.gsub(',', '') }
          .each { |field| write_type(field) }

    @output_file.puts('  end')
  end

  def write_type(field)
    trimmed_field = field.gsub(',', '')
    @output_file.puts("    @#{trimmed_field} = #{trimmed_field}")
  end

  def write_visitor_pattern(sub_class_name)
    visitor_target = "#{sub_class_name.downcase}_#{@base_class_name.downcase}"
    @output_file.puts('')
    @output_file.puts('  def accept(visitor)')
    @output_file.puts("    visitor.visit_#{visitor_target}(self)")
    @output_file.puts('  end')
  end

  def write_class_ending
    @output_file.puts('end')
    @output_file.puts('')
  end

  def accessors_from(fields)
    fields.split(', ').map { |f| ":#{f}" }.join(', ')
  end
end

GenerateAST.new(ARGV).run
