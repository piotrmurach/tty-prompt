# encoding: utf-8

require_relative 'converter_registry'

module TTY
  class Prompt
    module ConverterDSL
      def converter_registry
        @converter_registry ||= ConverterRegistry.new
      end

      def converter(name, &block)
        @converter_registry = converter_registry.register(name, &block)
        self
      end
    end # ConverterDSL
  end # Prompt
end # TTY
