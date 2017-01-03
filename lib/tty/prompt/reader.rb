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
      # Raised when the user hits the interrupt key(Control-C)
      #
      # @api public
      InputInterrupt = Class.new(StandardError)

      attr_reader :mode

      attr_reader :input

      attr_reader :output

      # Key codes
      CARRIAGE_RETURN = 13
      NEWLINE         = 10
      BACKSPACE       = 127
      DELETE          = 8

      CSI = "\e[".freeze

      # Initialize a Reader
      #
      # @api public
      def initialize(input, output, options = {})
        @input     = input
        @output    = output
        @mode      = Mode.new
        @interrupt = options.fetch(:interrupt) { :error }
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
              key = read_char.pack('U*')
              emit_key_event(key) if key
              handle_interrupt if key == Codes::CTRL_C
              key
            end
          end
        end
      end

      # Reads single character including invisible multibyte codes
      #
      # @params [Integer] bytes
      #   the number of bytes to read
      #
      # @return [String]
      #
      # @api public
      def read_char(codes = [])
        code = input.getc.ord rescue nil
        codes << code
        while (codes - "\e[".codepoints.to_a).empty? ||
              ("\e[".codepoints.to_a - codes).empty? &&
              !(64..126).include?(codes.last)
          read_char(codes)
        end
        codes.compact
      end

      # Get a single line from STDIN. Each key pressed is echoed
      # back to the shell. The input terminates when enter or
      # return key is pressed.
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
            while (codes = read_char) && (code = codes[0]) &&
                !(code == CARRIAGE_RETURN || code == NEWLINE)

              char = codes.pack('U*')
              emit_key_event(char)
              if code == BACKSPACE || code == DELETE
                line = line.slice(-1, 1) unless line.empty?
              else
                line << char
              end
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

      # Handle input interrupt based on provided value
      #
      # @api private
      def handle_interrupt
        case @interrupt
        when :signal
          Process.kill('SIGINT', Process.pid)
        when :exit
          exit(130)
        when Proc
          @interrupt.call
        when :noop
          return
        else
          raise InputInterrupt
        end
      end
    end # Reader
  end # Prompt
end # TTY
