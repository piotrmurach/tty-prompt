# encoding: utf-8

require 'wisper'
require 'tty/prompt/reader/key_event'
require 'tty/prompt/reader/mode'

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for reading character input from STDIN
    class Reader
      include Wisper::Publisher

      attr_reader :mode

      attr_reader :input

      attr_reader :output

      # Key input constants for decimal codes
      CARRIAGE_RETURN = 13.freeze
      NEWLINE         = 10.freeze
      BACKSPACE       = 127.freeze
      DELETE          = 8.freeze

      CSI = "\e[".freeze

      # Initialize a Reader
      #
      # @api public
      def initialize(input, output)
        @input  = input
        @output = output
        @mode   = Mode.new
      end

      # Get input in unbuffered mode.
      #
      # @example
      #   buffer do
      #     ...
      #   end
      #
      # @return [String]
      #
      # @api public
      def buffer(&block)
        bufferring = output.sync
        # Immediately flush output
        output.sync = true
        value = block.call if block_given?
        output.sync = bufferring
        value
      end

      # Read a single keypress that may include
      # 2 or 3 escape characters.
      #
      # @return [String]
      #
      # @api public
      def read_keypress
        buffer do
          mode.echo(false) do
            mode.raw(true) do
              key = read_char
              publish_keypress_event(key)
              exit 130 if key == Codes::CTRL_C
              key
            end
          end
        end
      end

      # Reads single character including invisible multibyte codes
      #
      # @return [String]
      #
      # @api public
      def read_char
        chars = input.sysread(1)
        while CSI.start_with?(chars) ||
              chars.start_with?(CSI) &&
              !(64..126).include?(chars.each_codepoint.to_a.last)
          next_char = read_char
          chars << next_char
        end
        chars
      end

      # Get a value from STDIN one key at a time. Each key press is echoed back
      # to the shell masked with character(if given). The input finishes when
      # enter key is pressed.
      #
      # @param [String] mask
      #   the character to use as mask
      #
      # @param [Boolean] echo
      #   echo back characters or not
      #
      # @return [String]
      #
      # @api public
      def read_line(mask = (not_set = true), echo = true)
        mask = false if not_set || mask.nil? || mask == false
        line = ''
        buffer do
          begin
            while (char = input.getbyte) &&
                !(char == CARRIAGE_RETURN || char == NEWLINE)
              publish_keypress_event(convert_byte(char))
              line = handle_char(line, char)
            end
          ensure
            mode.echo_on
          end
        end
        line
      end

      # Read multiple lines,
      #
      # @yield [String] line
      #
      # @return [Array[String]]
      #
      # @api public
      def read_multiline
        response = []
        loop do
          line = read_line
          break if !line || line == ''
          next  if line !~ /\S/
          if block_given?
            yield(line)
          else
            response << line
          end
        end
        response
      end

      # Publish event
      #
      # @param [String] key
      #   the key pressed
      #
      # @return [nil]
      #
      # @api public
      def publish_keypress_event(char)
        event = KeyEvent.from(char)
        event_name = parse_key_event(event)
        publish(event_name, event) unless event_name.nil?
        publish(:keypress, event)
      end

      # Interpret the key and provide event name
      #
      # @return [Symbol]
      #
      # @api public
      def parse_key_event(event)
        return if event.key.nil?
        permitted_events = %w(up down left right space return enter num)
        return unless permitted_events.include?("#{event.key.name}")
        :"key#{event.key.name}"
      end

      private

      trap('SIGINT') { exit 130 }

      # Convert byte to unicode character
      #
      # @return [String]
      #
      # @api private
      def convert_byte(byte)
        Array(byte).pack('U*')
      end

      # Handle single character by appending to or removing from output
      #
      # @api private
      def handle_char(line, char)
        if char == BACKSPACE || char == DELETE
          line.empty? ? line : line.slice(-1, 1)
        else
          line << char
        end
      end
    end # Reader
  end # Prompt
end # TTY
