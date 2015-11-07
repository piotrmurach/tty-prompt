# encoding: utf-8

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class responsible for reading character input from STDIN
    class Reader
      # @api private
      attr_reader :prompt
      private :prompt

      attr_reader :mode

      # Key input constants for decimal codes
      CARRIAGE_RETURN = 13.freeze
      NEWLINE         = 10.freeze
      BACKSPACE       = 127.freeze
      DELETE          = 8.freeze

      # Initialize a Reader
      #
      # @api public
      def initialize(prompt = Prompt.new)
        @prompt = prompt
        @mode  = Mode.new
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
        bufferring = prompt.output.sync
        # Immediately flush output
        prompt.output.sync = true

        value = block.call if block_given?

        prompt.output.sync = bufferring
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
              read_char
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
        chars = prompt.input.getc.chr
        if chars == "\e"
          chars = prompt.input.read_nonblock(3) rescue chars
          chars = prompt.input.read_nonblock(2) rescue chars
          chars = "\e" + chars
        end
        chars
      rescue
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
            while (char = prompt.input.getbyte) &&
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
        prompt.input.gets
      end

      # Reads at maximum +maxlen+ characters.
      #
      # @param [Integer] maxlen
      #
      # @api public
      def readpartial(maxlen)
        prompt.input.readpartial(maxlen)
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
        prompt.output.putc((not_set || !mask) ? char : mask)
      end
    end # Reader
  end # Prompt
end # TTY
