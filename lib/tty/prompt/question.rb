# encoding: utf-8

require 'tty/prompt/question/modifier'
require 'tty/prompt/question/validation'

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for gathering user input
    #
    # @api public
    class Question
      # Store question message
      # @api public
      attr_reader :message

      # Store default value.
      #
      # @api private
      attr_reader :default_value

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
        @modifier      = Modifier.new options.fetch(:modifier) { [] }
        @validation    = Validation.new(options.fetch(:validation) { nil })
        @default       = options.fetch(:default) { nil }
        @read          = options.fetch(:read) { nil }
        @color         = options.fetch(:color) { :green }
        @error         = false
        @converter     = Necromancer.new
        @done          = false
      end

      # Call the quesiton
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
        render_question
        reader = Reader.new(@prompt)
        @raw_input, @answer = Response.new(self, reader).read_type(@read)
        @raw_input = @default if blank?(@raw_input)
        @done = true
        refresh
        render_question
        @answer
      ensure
        @answer
      end

      # Render quesiton
      #
      # @api private
      def render_question
        header = "#{prompt.prefix}#{message} "
        if !echo?  #|| mask?
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
      def refresh
        lines = @message.scan("\n").length + 1
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
      def default(value)
        return @default unless value
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

      # Set validation rule for an argument
      #
      # @param [Object] value
      #
      # @return [Question]
      #
      # @api public
      def validate(value = nil, &block)
        @validation = Validation.new(value || block)
      end

      # Modify string according to the rule given.
      #
      # @param [Symbol] rule
      #
      # @api public
      def modify(*rules)
        @modifier = Modifier.new(*rules)
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
      def in(value = nil)
        return @in if value.nil?
        @in = @converter.convert(value).to(:range, strict: true)
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
        return @default if !input && default?
        check_required(input)
        return if input.nil?

        within?(input)
        validation.(input)
        modifier.apply_to(input)
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

      private

      # Check if value is present
      #
      # @api private
      def check_required(value)
        if @required && !default? && value.nil?
          fail ArgumentRequired, 'No value provided for required'
        end
      end

      # Check if value is within expected range
      #
      # @api private
      def within?(value)
        if in? && value
          @in.include?(value) || fail(InvalidArgument,
            "Value #{value} is not included in the range #{@in}")
        end
      end
    end # Question
  end # Prompt
end # TTY
