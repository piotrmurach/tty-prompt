# encoding: utf-8

require 'wisper'
require 'tty/prompt/reader/key_event'
require 'tty/prompt/reader/mode'

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for reading character input from STDIN
    #
    # Used internally to provide key and line reading functionality
    #
    # @api private
    class Reader
      include Wisper::Publisher

      attr_reader :mode

      attr_reader :input

      attr_reader :output

      # Key input constants for decimal codes
      CARRIAGE_RETURN = 13
      NEWLINE         = 10
      BACKSPACE       = 127
      DELETE          = 8

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
      # @param [Boolean] echo
      #   whether to echo chars back or not, defaults to false
      #
      # @return [String]
      #
      # @api public
      def read_keypress(echo = false)
        buffer do
          mode.echo(echo) do
            mode.raw(true) do
              key = read_char
              emit_key_event(key) if key
              Process.kill('SIGINT', Process.pid) if key == Codes::CTRL_C
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
      rescue EOFError
        # Finished processing
        chars
      end

      # Get a single line from STDIN
      # Each key pressed is echoed back  to the shell.
      # The input terminates when enter or return key is pressed.
      #
      # @param [Boolean] echo
      #   if true echo back characters, output nothing otherwise
      #
      # @return [String]
      #
      # @api public
      def read_line(echo = true)
        line = ''
        buffer do
          mode.echo(echo) do
            while (char = input.getbyte) &&
                !(char == CARRIAGE_RETURN || char == NEWLINE)
              emit_key_event(convert_byte(char))
              line = handle_char(line, char)
            end
          end
        end
        line
      end

      # Read multiple lines and terminate when empty line is submitted.
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
      def emit_key_event(key)
        event = KeyEvent.from(key)
        publish(:"key#{event.key.name}", event) if event.emit?
        publish(:keypress, event)
      end

      private

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
