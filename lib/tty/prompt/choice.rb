# encoding: utf-8

module TTY
  class Prompt
    # A single choice option
    #
    # @api public
    class Choice
      # The label name
      #
      # @api public
      attr_reader :name

      attr_reader :key

      # Create a Choice instance
      #
      # @api public
      def initialize(name, value, key = nil)
        @name  = name
        @value = value
        @key   = key
      end

      # Create choice from value
      #
      # @example
      #   Choice.from(:option_1)
      #   Choice.from([:option_1, 1])
      #
      # @param [Object] val
      #   the value to be converted
      #
      # @raise [ArgumentError]
      #
      # @return [Choice]
      #
      # @api public
      def self.from(val)
        case val
        when Choice
          val
        when String, Symbol
          new(val, val)
        when Array
          new("#{val.first}", val.last)
        when Hash
          if val.key?(:name)
            new("#{val[:name]}", val[:value], val[:key])
          else
            new("#{val.keys.first}", val.values.first)
          end
        else
          raise ArgumentError, "#{val} cannot be coerced into Choice"
        end
      end

      # Read value and evaluate
      #
      # @api public
      def value
        case @value
        when Proc
          @value.call
        else
          @value
        end
      end

      # Object equality comparison
      #
      # @return [Boolean]
      #
      # @api public
      def ==(other)
        return false unless other.is_a?(self.class)
        name == other.name && value == other.value
      end

      # Object string representation
      #
      # @return [String]
      #
      # @api public
      def to_s
        "#{name}"
      end
    end # Choice
  end # Prompt
end # TTY
