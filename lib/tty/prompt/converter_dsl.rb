# frozen_string_literal: true

require_relative "converter_registry"

module TTY
  class Prompt
    module ConverterDSL
      def converter_registry
        @__converter_registry ||= ConverterRegistry.new
      end

      def converter(name, &block)
        converter_registry.register(name, &block)
      end

      def convert(name, input)
        converter_registry[name].call(input)
      end
    end # ConverterDSL
  end # Prompt
end # TTY
