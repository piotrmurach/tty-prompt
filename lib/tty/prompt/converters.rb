# frozen_string_literal: true

require "necromancer"

require_relative "const"
require_relative "converter_dsl"

module TTY
  class Prompt
    module Converters
      extend ConverterDSL

      TRUE_VALUES = /^(t(rue)?|y(es)?|on|1)$/i.freeze
      FALSE_VALUES = /^(f(alse)?|n(o)?|off|0)$/i.freeze

      converter(:boolean, :bool) do |input|
        case input.to_s
        when TRUE_VALUES then true
        when FALSE_VALUES then false
        else Const::Undefined
        end
      end

      converter(:string, :str) do |input|
        String(input).chomp
      end

      converter(:symbol, :sym) do |input|
        input.to_sym
      end

      converter(:char) do |input|
        String(input).chars.to_a[0]
      end

      converter(:date) do |input|
        begin
          require "date" unless defined?(::Date)
          ::Date.parse(input)
        rescue ArgumentError
          Const::Undefined
        end
      end

      converter(:datetime) do |input|
        begin
          require "date" unless defined?(::Date)
          ::DateTime.parse(input.to_s)
        rescue ArgumentError
          Const::Undefined
        end
      end

      converter(:time) do |input|
        begin
          require "time"
          ::Time.parse(input.to_s)
        rescue ArgumentError
          Const::Undefined
        end
      end

      converter(:integer, :int) do |input|
        begin
          Integer(input)
        rescue ArgumentError
          Const::Undefined
        end
      end

      converter(:float) do |input|
        begin
          Float(input)
        rescue TypeError, ArgumentError
          Const::Undefined
        end
      end

      converter(:range) do |input|
        begin
          Necromancer.convert(input).to(:range, strict: true)
        rescue Necromancer::ConversionTypeError
          Const::Undefined
        end
      end

      converter(:regexp) do |input|
        Regexp.new(input)
      end

      converter(:filepath, :file) do |input|
        ::File.expand_path(input)
      end

      converter(:pathname, :path) do |input|
        require "pathname" unless defined?(::Pathname)
        ::Pathname.new(input)
      end

      converter(:uri) do |input|
        require "uri" unless defined?(::URI)
        ::URI.parse(input)
      end
    end # Converters
  end # Prompt
end # TTY
