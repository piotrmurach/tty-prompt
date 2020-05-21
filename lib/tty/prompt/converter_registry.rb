# frozen_string_literal: true

module TTY
  class Prompt
    # Immutable collection of converters for type transformation
    #
    # @api private
    class ConverterRegistry
      # Create a registry of conversions
      #
      # @param [Hash] registry
      #
      # @api private
      def initialize(registry = {})
        @__registry = registry.dup
      end

      # Check if conversion is available
      #
      # @param [String] name
      #
      # @return [Boolean]
      #
      # @api public
      def contain?(name)
        conv_name = name.to_s.downcase.to_sym
        @__registry.key?(conv_name)
      end

      # Register a conversion
      #
      # @param [Symbol] name
      #   the converter name
      #
      # @api public
      def register(*names, &block)
        names.each do |name|
          if contain?(name)
            raise ArgumentError,
                  "converter for #{name.inspect} is already registered"
          end
          @__registry[name] = block
        end
      end

      # Execute converter
      #
      # @api public
      def [](name)
        conv_name = name.to_s.downcase.to_sym
        @__registry.fetch(conv_name) do
          raise ArgumentError, "converter #{conv_name.inspect} is not registered"
        end
      end
      alias fetch []

      def inspect
        @_registry.inspect
      end
    end # ConverterRegistry
  end # Prompt
end # TTY
