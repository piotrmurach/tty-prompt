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

      UndefinedSetting = Module.new

      # Store question message
      # @api public
      attr_reader :message

      attr_reader :modifier

      attr_reader :prompt

      attr_reader :validation

      # Initialize a Question
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt     = prompt
        @default    = options.fetch(:default) { UndefinedSetting }
        @required   = options.fetch(:required) { false }
        @echo       = options.fetch(:echo) { true }
        @in         = options.fetch(:in) { UndefinedSetting }
        @modifier   = options.fetch(:modifier) { [] }
        @validation = options.fetch(:validation) { UndefinedSetting }
        @read       = options.fetch(:read) { UndefinedSetting }
        @convert    = options.fetch(:convert) { UndefinedSetting }
        @color      = options.fetch(:color) { :green }
        @messages   = Utils.deep_copy(options.fetch(:messages) { { } })
        @done       = false
        @input      = nil

        @evaluator = Evaluator.new(self)

        @evaluator << CheckRequired
        @evaluator << CheckDefault
        @evaluator << CheckRange
        @evaluator << CheckValidation
        @evaluator << CheckModifier
      end

      # Stores all the error messages displayed to user
      # The currently supported messages are:
      #  * :range?
      #  * :required?
      #  * :valid?
      attr_reader :messages

      # Retrieve message based on the key
      #
      # @param [Symbol] name
      #   the name of message key
      #
      # @param [Hash] tokens
      #   the tokens to evaluate
      #
      # @return [Array[String]]
      #
      # @api private
      def message_for(name, tokens = nil)
        template = @messages[name]
        if template && !template.match(/\%\{/).nil?
          [template % tokens]
        else
          [template || '']
        end
      end

      # Call the question
      #
      # @param [String] message
      #
      # @return [self]
      #
      # @api public
      def call(message, &block)
        return if Utils.blank?(message)
        @message = message
        block.call(self) if block
        render
      end

      # Read answer and convert to type
      #
      # @api private
      def render
        until @done
          render_question
          result = process_input
          errors = result.errors
          render_error_or_finish(result)
          refresh(errors.count)
        end
        render_question
        convert_result(result.value)
      end

      # Render question
      #
      # @api private
      def render_question
        header = "#{prompt.prefix}#{message} "
        if @convert == :bool && !@done
          if converted_default
            suffix = '(Y/n)'
          else
            suffix = '(y/N)'
          end
          header += @prompt.decorate(suffix, :bright_black) + ' '
        elsif !echo?
          header
        elsif @done
          header += @prompt.decorate("#{@input}", @color)
        elsif default?
          header += @prompt.decorate("(#{default})", :bright_black) + ' '
        end
        @prompt.print(header)
        @prompt.print("\n") if @done
      end

      # Decide how to handle input from user
      #
      # @api private
      def process_input
        @input = read_input
        if Utils.blank?(@input)
          @input = default? ? default : nil
        end
        @evaluator.(@input)
      end

      # Process input
      #
      # @api private
      def read_input
        case @read
        when :keypress
          @prompt.read_keypress
        when :multiline
          @prompt.read_multiline
        else
          @prompt.read_line(echo)
        end
      end

      # Handle error condition
      #
      # @api private
      def render_error_or_finish(result)
        if result.failure?
          result.errors.each do |err|
            @prompt.print(@prompt.clear_line)
            @prompt.print(@prompt.decorate('>>', :red) + ' ' + err)
          end
          @prompt.print(@prompt.cursor.up(result.errors.count))
        else
          @done = true
          if result.errors.count.nonzero?
            @prompt.print(@prompt.cursor.down(result.errors.count))
          end
        end
      end

      # Determine area of the screen to clear
      #
      # @param [Integer] errors
      #
      # @api private
      def refresh(errors = nil)
        lines = @message.scan("\n").length
        lines += ((!echo? || errors.nonzero?) ? 1 : 2) # clear user enter

        if errors.nonzero? && @done
          lines += errors
        end

        @prompt.print(@prompt.clear_lines(lines))
      end

      # Convert value to expected type
      #
      # @param [Object] value
      #
      # @api private
      def convert_result(value)
        if convert? & !Utils.blank?(value)
          converter_registry.(@convert, value)
        else
          value
        end
      end

      # Convert default value by convert
      #
      # @api private
      def converted_default
        if default?
          convert_result(default)
        else
          default
        end
      end

      # Set reader type
      #
      # @api public
      def read(value)
        @read = value
      end

      # Specify answer conversion
      #
      # @api public
      def convert(value)
        @convert = value
      end

      # Check if conversion is set
      #
      # @return [Boolean]
      #
      # @api public
      def convert?
        @convert != UndefinedSetting
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
        @default != UndefinedSetting
      end

      # Ensure that passed argument is present or not
      #
      # @return [Boolean]
      #
      # @api public
      def required(value = (not_set = true), message = nil)
        messages[:required?] = message if message
        return @required if not_set
        @required = value
      end
      alias_method :required?, :required

      # Set validation rule for an argument
      #
      # @param [Object] value
      #
      # @return [Question]
      #
      # @api public
      def validate(value = nil, message = nil, &block)
        messages[:valid?] = message if message
        @validation = (value || block)
      end

      def validation?
        @validation != UndefinedSetting
      end

      # Modify string according to the rule given.
      #
      # @param [Symbol] rule
      #
      # @api public
      def modify(*rules)
        @modifier = rules
      end

      # Turn terminal echo on or off. This is used to secure the display so
      # that the entered characters are not echoed back to the screen.
      #
      # @api public
      def echo(value = nil)
        return @echo if value.nil?
        @echo = value
      end
      alias_method :echo?, :echo

      # Turn raw mode on or off. This enables character-based input.
      #
      # @api public
      def raw(value = nil)
        return @raw if value.nil?
        @raw = value
      end
      alias_method :raw?, :raw

      # Set expected range of values
      #
      # @param [String] value
      #
      # @api public
      def in(value = (not_set = true), message = nil)
        messages[:range?] = message if message
        if in? && !@in.is_a?(Range)
          @in = converter_registry.(:range, @in)
        end
        return @in if not_set
        @in = converter_registry.(:range, value)
      end

      # Check if range is set
      #
      # @return [Boolean]
      #
      # @api public
      def in?
        @in != UndefinedSetting
      end

      # @api public
      def to_s
        "#{message}"
      end

      # String representation of this question
      # @api public
      def inspect
        "#<#{self.class.name} @message=#{message}, @input=#{@input}>"
      end
    end # Question
  end # Prompt
end # TTY
