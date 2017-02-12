# encoding: utf-8

require_relative 'converter_registry'

module TTY
  class Prompt
    module ConverterDSL
      def self.extended(base)
        attr_reader :converter_registry

        base.instance_variable_set(:@converter_registry, ConverterRegistry.new)
      end

      def converter(name, &block)
        converter_registry.register(name, &block)
      end
    end # ConverterDSL
  end # Prompt
end # TTY
