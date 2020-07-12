# frozen_string_literal: true

require_relative "const"
require_relative "converter_dsl"

module TTY
  class Prompt
    module Converters
      extend ConverterDSL

      TRUE_VALUES = /^(t(rue)?|y(es)?|on|1)$/i.freeze
      FALSE_VALUES = /^(f(alse)?|n(o)?|off|0)$/i.freeze

      SINGLE_DIGIT_MATCHER = /^(?<digit>\-?\d+(\.\d+)?)$/.freeze
      DIGIT_MATCHER = /^(?<open>-?\d+(\.\d+)?)
                       \s*(?<sep>(\.\s*){2,3}|-|,)\s*
                       (?<close>-?\d+(\.\d+)?)$
                      /x.freeze
      LETTER_MATCHER = /^(?<open>\w)
                        \s*(?<sep>(\.\s*){2,3}|-|,)\s*
                        (?<close>\w)$
                       /x.freeze

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

      # Convert string number to integer or float
      #
      # @return [Integer,Float,Const::Undefined]
      #
      # @api private
      def cast_to_num(num)
        ([convert(:int, num), convert(:float, num)] - [Const::Undefined]).first ||
          Const::Undefined
      end
      module_function :cast_to_num

      converter(:range) do |input|
        if input.is_a?(::Range)
          input
        elsif match = input.to_s.match(SINGLE_DIGIT_MATCHER)
          digit = cast_to_num(match[:digit])
          ::Range.new(digit, digit)
        elsif match = input.to_s.match(DIGIT_MATCHER)
          open = cast_to_num(match[:open])
          close = cast_to_num(match[:close])
          ::Range.new(open, close, match[:sep].gsub(/\s*/, "") == "...")
        elsif match = input.to_s.match(LETTER_MATCHER)
          ::Range.new(match[:open], match[:close],
                      match[:sep].gsub(/\s*/, "") == "...")
        else Const::Undefined
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

      converter(:list, :array) do |val|
        (val.respond_to?(:to_a) ? val : val.split(/(?<!\\),/))
          .map { |v| v.strip.gsub(/\\,/, ",") }
          .reject(&:empty?)
      end

    end # Converters
  end # Prompt
end # TTY
