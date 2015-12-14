# encoding: utf-8

require 'tty/prompt/question/modifier'
require 'tty/prompt/question/validation'
require 'tty/prompt/question/checks'
require 'tty/prompt/converter_dsl'
require 'tty/prompt/converters'

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for gathering user input
    #
    # @api public
    class Question
      include Checks
      include Converters

      # Store question message
      # @api public
      attr_reader :message

      attr_reader :validation

      # Controls character processing of the answer
      #
      # @api public
      attr_reader :modifier

      attr_reader :error

      # Returns character mode
      #
      # @api public
      attr_reader :character

      # @api private
      attr_reader :prompt

      attr_reader :converter

      BLANK_REGEX = /\A[[:space:]]*\z/o.freeze

      # Initialize a Question
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt        = prompt
        @required      = options.fetch(:required) { false }
        @echo          = options.fetch(:echo) { true }
        @raw           = options.fetch(:raw) { false }
        @mask          = options.fetch(:mask) { false  }
        @character     = options.fetch(:character) { false }
        @in            = options.fetch(:in) { false }
        @modifier      = options.fetch(:modifier) { [] }
        @validation    = options.fetch(:validation) { nil }
        @default       = options.fetch(:default) { nil }
        @read          = options.fetch(:read) { nil }
        @color         = options.fetch(:color) { :green }
        @error         = false
        @done          = false
      end

      # Call the question
      #
      # @param [String] message
      #
      # @return [self]
      #
      # @api public
      def call(message, &block)
        return if blank?(message)
        @message = message
        block.call(self) if block
        render
      end

      # Read answer and convert to type
      #
      # @api private
      def render
        @answer = nil
        @raw_input = nil
        errors = []

        until @done
          render_question

          # process_input
          @raw_input = process_input
          @input     = conversion(@raw_input, @read)
          @raw_input = @default if blank?(@raw_input)
          result = evaluate_response(@input)

          if result.failure?
            errors = result.errors
            errors.each do |err|
              @prompt.output.print(@prompt.cursor.clear_line)
              @prompt.output.puts(@prompt.decorate('>>', :red) + ' ' + err)
            end
          else
            @done = true
          end

          refresh_screen(errors)
        end
        render_question
        @answer = result.value
      ensure
        @answer
      end

      def reader
        @prompt.reader
      end

      # Process input
      #
      # @api private
      def read_input
        if mask? && echo?
          reader.getc(mask)
        else
          reader.mode.echo(echo) do
            reader.mode.raw(raw) do
              if raw?
                reader.readpartial(10)
              elsif character?
                reader.getc(mask)
              else
                reader.gets
              end
            end
          end
        end
      end

      def conversion(input, type = nil)
        if blank?(input)
          nil
        elsif !type.nil? && converter_registry.key?(type)
          converter_registry.(type, input)
        else input
        end
      end

      # Read input from STDIN and convert
      #
      # @param [Symbol] type
      #
      # @return [undefined]
      #
      # @api private
      def process_input
        read_input
      end

      # Render quesiton
      #
      # @api private
      def render_question
        header = "#{prompt.prefix}#{message} "
        if @read == :bool && !@done
          header += @prompt.decorate('(Y/n)', :bright_black) + ' '
        elsif !echo?
          header
        elsif mask?
          header += "#{@mask * "#{@raw_input}".length}"
        elsif @done
          header += @prompt.decorate("#{@raw_input}", @color)
        elsif @default
          header += @prompt.decorate("(#{@default})", :bright_black) + ' '
        end
        @prompt.output.print(header)
      end

      # Determine area of the screen to clear
      #
      # @api private
      def refresh_screen(errors = nil)
        lines = @message.scan("\n").length + 1

        if errors.count.nonzero?
          @prompt.output.print(@prompt.cursor.up(errors.count))
          if @done
            @prompt.output.print(@prompt.clear_lines(errors.count, :down))
          end
        end
        @prompt.output.print(@prompt.clear_lines(lines))
      end

      # Set reader type
      #
      # @api public
      def read(value)
        @read = value
      end

      # Set default value.
      #
      # @api public
      def default(value = (not_set = true))
        return @default if not_set
        @default = value
      end

      # Check if default value is set
      #
      # @return [Boolean]
      #
      # @api public
      def default?
        !!@default
      end

      # Ensure that passed argument is present or not
      #
      # @return [Boolean]
      #
      # @api public
      def required(value)
        @required = value
      end

      def required?
        @required
      end

      # Set validation rule for an argument
      #
      # @param [Object] value
      #
      # @return [Question]
      #
      # @api public
      def validate(value = nil, &block)
        @validation = (value || block)
      end

      # Modify string according to the rule given.
      #
      # @param [Symbol] rule
      #
      # @api public
      def modify(*rules)
        @modifier = rules
      end

      # Setup behaviour when error(s) occur
      #
      # @api public
      def on_error(action = nil)
        @error = action
      end

      # Check if error behaviour is set
      #
      # @api public
      def error?
        !!@error
      end

      # Turn terminal echo on or off. This is used to secure the display so
      # that the entered characters are not echoed back to the screen.
      #
      # @api public
      def echo(value = nil)
        return @echo if value.nil?
        @echo = value
      end

      # Chec if echo is set
      #
      # @api public
      def echo?
        !!@echo
      end

      # Turn raw mode on or off. This enables character-based input.
      #
      # @api public
      def raw(value = nil)
        return @raw if value.nil?
        @raw = value
      end

      # Check if raw mode is set
      #
      # @api public
      def raw?
        !!@raw
      end

      # Set character for masking the STDIN input
      #
      # @param [String] character
      #
      # @return [self]
      #
      # @api public
      def mask(char = nil)
        return @mask if char.nil?
        @mask = char
      end

      # Check if character mask is set
      #
      # @return [Boolean]
      #
      # @api public
      def mask?
        !!@mask
      end

      # Set if the input is character based or not
      #
      # @param [Boolean] value
      #
      # @return [self]
      #
      # @api public
      def char(value = nil)
        return @character if value.nil?
        @character = value
      end

      # Check if character intput is set
      #
      # @return [Boolean]
      #
      # @api public
      def character?
        !!@character
      end

      # Set expect range of values
      #
      # @param [String] value
      #
      # @api public
      def in(value = (not_set = true))
        return @in if not_set
        @in = converter_registry.(:range, value)
      end

      # Check if range is set
      #
      # @return [Boolean]
      #
      # @api public
      def in?
        !!@in
      end

      # Check if response matches all the requirements set by the question
      #
      # @param [Object] value
      #
      # @return [Object]
      #
      # @api private
      def evaluate_response(input)
        evaluator = Evaluator.new(self)

        evaluator << CheckRequired
        evaluator << CheckDefault
        evaluator << CheckRange
        evaluator << CheckValidation
        evaluator << CheckModifier

        evaluator.(input)
      end

      # Reset question object.
      #
      # @api public
      def clean
        @message  = nil
        @default  = nil
        @required = false
        @modifier = nil
      end

      def blank?(value)
        value.nil? ||
        value.respond_to?(:empty?) && value.empty? ||
        BLANK_REGEX === value
      end

      def to_s
        "#{message}"
      end

      def inspect
        "#<Question @message=#{message}>"
      end
    end # Question
  end # Prompt
end # TTY
