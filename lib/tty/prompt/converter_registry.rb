# encoding: utf-8

module TTY
  class Prompt
    class ConverterRegistry
      def initialize
        @_registry = {}
      end

      # Register converter
      #
      # @api public
      def register(key, contents = nil, &block)
        if block_given?
          item = block
        else
          item = contents
        end

        if key?(key)
          fail ArgumentError, "Converter for #{key.inspect} already registered"
        else
          @_registry[key] = item
        end
        self
      end

      # Check if converter is registered
      #
      # @return [Boolean]
      #
      # @api public
      def key?(key)
        @_registry.key?(key)
      end

      # Execute converter
      #
      # @api public
      def call(key, input)
        if key.respond_to?(:call)
          converter = key
        else
          converter = @_registry.fetch(key) do
            fail ArgumentError, "#{key.inspect} is not registered"
          end
        end
        converter.call(input)
      end

      def inspect
        @_registry.inspect
      end
    end # ConverterRegistry
  end # Prompt
end # TTY
