# encoding: utf-8

module TTY
  class Prompt
    class Question
      # A class representing question validation.
      class Validation
        attr_reader :pattern

        # Initialize a Validation
        #
        # @param [Object] pattern
        #
        # @return [undefined]
        #
        # @api private
        def initialize(pattern)
          @pattern = coerce(pattern)
        end

        # Convert validation into known type.
        #
        # @param [Object] validation
        #
        # @raise [TTY::ValidationCoercion] failed to convert validation
        #
        # @api private
        def coerce(pattern)
          case pattern
          when Proc
            pattern
          when Regexp, String
            Regexp.new(pattern.to_s)
          else
            fail ValidationCoercion, "Wrong type, got #{pattern.class}"
          end
        end

        # Test if the input passes the validation
        #
        # @example
        #   Validation.new
        #   validation.valid?(input) # => true
        #
        # @param [Object] input
        #  the input to validate
        #
        # @return [Boolean]
        #
        # @api public
        def call(input)
          if pattern.is_a?(Regexp)
            !pattern.match(input).nil?
          elsif pattern.is_a?(Proc)
            result = pattern.call(input)
            result.nil? ? false : result
          else false
          end
        end
      end # Validation
    end # Question
  end # Prompt
end # TTY
