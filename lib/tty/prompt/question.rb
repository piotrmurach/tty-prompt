# encoding: utf-8

require_relative 'converters'
require_relative 'evaluator'
require_relative 'question/modifier'
require_relative 'question/validation'
require_relative 'question/checks'
require_relative 'utils'

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for gathering user input
    #
    # @api public
    class Question
      include Checks

      UndefinedSetting = Module.new

      # Store question message
      # @api public
      attr_reader :message

      attr_reader :modifier

      attr_reader :validation

      # Initialize a Question
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt     = prompt
        @prefix     = options.fetch(:prefix) { @prompt.prefix }
        @default    = options.fetch(:default) { UndefinedSetting }
        @required   = options.fetch(:required) { false }
        @echo       = options.fetch(:echo) { true }
        @in         = options.fetch(:in) { UndefinedSetting }
        @modifier   = options.fetch(:modifier) { [] }
        @validation = options.fetch(:validation) { UndefinedSetting }
        @read       = options.fetch(:read) { UndefinedSetting }
        @convert    = options.fetch(:convert) { UndefinedSetting }
        @active_color = options.fetch(:active_color) { @prompt.active_color }
        @help_color = options.fetch(:help_color) { @prompt.help_color }
        @error_color = options.fetch(:error_color)  { :red }
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
        @errors = []
        until @done
          lines = render_question
          result = process_input
          if result.failure?
            @errors = result.errors
            render_error(result.errors)
          else
            @done = true
          end
          refresh(lines)
        end
        render_question
        convert_result(result.value)
      end

      # Render question
      #
      # @api private
      def render_question
        header = "#{@prefix}#{message} "
        if !echo?
          header
        elsif @done
          header += @prompt.decorate("#{@input}", @active_color)
        elsif default? && !Utils.blank?(@default)
          header += @prompt.decorate("(#{default})", @help_color) + ' '
        end
        @prompt.print(header)
        @prompt.puts if @done

        header.lines.count + (@done ? 1 : 0)
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
          @prompt.read_multiline.each(&:chomp!)
        else
          @prompt.read_line(echo: echo).chomp
        end
      end

      # Handle error condition
      #
      # @api private
      def render_error(errors)
        errors.each do |err|
          newline = (@echo ? '' : "\n")
          @prompt.print(newline + @prompt.decorate('>>', :red) + ' ' + err)
        end
      end

      # Determine area of the screen to clear
      #
      # @param [Array[String]] errors
      #
      # @api private
      def refresh(lines)
        if @done
          if @errors.count.zero? && @echo
            @prompt.print(@prompt.cursor.up(lines))
          else
            lines += @errors.count
          end
        else
          @prompt.print(@prompt.cursor.up(lines))
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
          Converters.convert(@convert, value)
        else
          value
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
          @in = Converters.convert(:range, @in)
        end
        return @in if not_set
        @in = Converters.convert(:range, value)
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
