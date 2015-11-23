# encoding: utf-8

module TTY
  class Prompt
    class Question
      # A class representing question validation.
      class Validation
        # @api private
        attr_reader :validation
        private :validation

        # Initialize a Validation
        #
        # @param [Object] validation
        #
        # @return [undefined]
        #
        # @api private
        def initialize(validation = nil)
          @validation = validation ? coerce(validation) : validation
        end

        # Convert validation into known type.
        #
        # @param [Object] validation
        #
        # @raise [TTY::ValidationCoercion] failed to convert validation
        #
        # @api private
        def coerce(validation)
          case validation
          when Proc
            validation
          when Regexp, String
            Regexp.new(validation.to_s)
          else
            fail ValidationCoercion, "Wrong type, got #{validation.class}"
          end
        end

        # Check if validation is required
        #
        # @return [Boolean]
        #
        # @api public
        def validate?
          !!validation
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
          if validate? && input
            input = input.to_s
            if validation.is_a?(Regexp) && validation =~ input
            elsif validation.is_a?(Proc) && validation.call(input)
            else fail InvalidArgument, "Invalid input for #{input}"
            end
            true
          else
            false
          end
        end
      end # Validation
    end # Question
  end # Prompt
end # TTY
