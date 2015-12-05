# encoding: utf-8

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for reading character input from STDIN
    class Reader
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
        chars = input.read_nonblock(1) rescue chars
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
      # @return [String]
      #
      # @api public
      def getc(mask = (not_set = true))
        value = ''
        buffer do
          begin
            while (char = input.getbyte) &&
                !(char == CARRIAGE_RETURN || char == NEWLINE)
              value = handle_char value, char, not_set, mask
            end
          ensure
            mode.echo_on
          end
        end
        value
      end

      # Get a value from STDIN using line input.
      #
      # @api public
      def gets
        input.gets
      end

      # Reads at maximum +maxlen+ characters.
      #
      # @param [Integer] maxlen
      #
      # @api public
      def readpartial(maxlen)
        input.readpartial(maxlen)
      end

      private

      # Handle single character by appending to or removing from output
      #
      # @api private
      def handle_char(value, char, not_set, mask)
        if char == BACKSPACE || char == DELETE
          value.slice!(-1, 1) unless value.empty?
        else
          print_char char, not_set, mask
          value << char
        end
        value
      end

      # Print out character back to shell STDOUT
      #
      # @api private
      def print_char(char, not_set, mask)
        output.putc((not_set || !mask) ? char : mask)
      end
    end # Reader
  end # Prompt
end # TTY
