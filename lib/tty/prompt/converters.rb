# encoding: utf-8

require 'pathname'
require 'necromancer'
require 'tty/prompt/converter_dsl'

module TTY
  class Prompt
    module Converters
      extend ConverterDSL

      def self.included(base)
        base.class_eval do
          def converter_registry
            Converters.converter_registry
          end
        end
      end

      def self.on_error
        yield
      rescue Necromancer::ConversionTypeError => e
        raise ConversionError, e.message
      end

      converter(:bool) do |input|
        converter = Necromancer.new
        on_error { converter.convert(input).to(:boolean, strict: true) }
      end

      converter(:string) do |input|
        String(input).chomp
      end

      converter(:symbol) do |input|
        input.to_sym
      end

      converter(:date) do |input|
        converter = Necromancer.new
        on_error { converter.convert(input).to(:date, strict: true) }
      end

      converter(:datetime) do |input|
        converter = Necromancer.new
        on_error { converter.convert(input).to(:datetime, strict: true) }
      end

      converter(:int) do |input|
        converter = Necromancer.new
        on_error { converter.convert(input).to(:integer, strict: true) }
      end

      converter(:float) do |input|
        converter = Necromancer.new
        on_error { converter.convert(input).to(:float, strict: true) }
      end

      converter(:range) do |input|
        converter = Necromancer.new
        on_error { converter.convert(input).to(:range, strict: true) }
      end

      converter(:regexp) do |input|
        Regexp.new(input)
      end

      converter(:file) do |input|
        directory = File.expand_path(File.dirname($0))
        File.open(File.join(directory, input))
      end

      converter(:path) do |input|
        directory = File.expand_path(File.dirname($0))
        Pathname.new(File.join(directory, input))
      end

      converter(:char) do |input|
        String(input).chars.to_a[0]
      end
    end # Converters
  end # Prompt
end # TTY
