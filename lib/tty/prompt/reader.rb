# encoding: utf-8

require 'wisper'
require 'rbconfig'
require 'tty/prompt/reader/key_event'
require 'tty/prompt/reader/console'
require 'tty/prompt/reader/win_console'
require 'tty/prompt/reader/codes'

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

      attr_reader :input

      attr_reader :output

      # Key codes
      CARRIAGE_RETURN = 13
      NEWLINE         = 10
      BACKSPACE       = 127
      DELETE          = 8

      # Initialize a Reader
      #
      # @api public
      def initialize(input, output, options = {})
        @input     = input
        @output    = output
        @console   = windows? ? WinConsole.new : Console.new(input)
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

      # Read a keypress and return a character as a string.
      # Nothing is echoed to the console. This call will block for a
      # single keypress, but will not wait for Enter to be pressed.
      #
      # @param [Boolean] echo
      #   whether to echo chars back or not, defaults to false
      #
      # @return [String]
      #
      # @api public
      def read_keypress(options = {})
        opts = { echo: false, raw: true }.merge(options)
        codes = get_codes(opts)
        emit_key_event(codes) if codes
        handle_interrupt if codes == Codes.keys[:ctrl_c]
        codes.pack('U*') if codes
      end

      # Reads single character including invisible multibyte codes
      #
      # @params [Array[Integer]] codes
      #   the number of bytes to read
      #
      # @return [Array[Integer]]
      #   the character codepoints
      #
      # @api public
      def read_char(options = {})
        codes = get_codes(options)
        emit_key_event(codes) if codes
        codes.pack('U*')  if codes
      end

      # Get input bytes
      #
      # @param [Hash[Symbol]] options
      # @param [Array[Integer]] codes
      #
      # @api private
      def get_codes(options = {}, codes = [])
        char = @console.get_char(options)
        return if char.nil?
        codes << char.ord

        condition = proc { |escape|
          (codes - escape).empty? ||
          (escape - codes).empty? &&
          !(64..126).include?(codes.last)
        }

        while @console.escape_codes.any?(&condition)
          get_codes(options, codes)
        end
        codes
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
      def read_line(options = {})
        opts = { echo: true, raw: false }.merge(options)
        line = ''
        while (codes = get_codes(opts)) && (code = codes[0])

          emit_key_event(codes)
          delete_char = proc { |c| c == BACKSPACE || c == DELETE }

          if delete_char[code]
            line = line.slice(-1, 1) unless line.empty?
            backspaces = line.size
          else
            line << codes.pack('U*')
          end

          break if (code == CARRIAGE_RETURN || code == NEWLINE)

          if delete_char[code]
            if backspaces >= 0
              output.print("\e[#{backspaces}X")
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
      def emit_key_event(codes)
        event = KeyEvent.from(@console.keys, codes)
        publish(:"key#{event.key.name}", event) if event.emit?
        publish(:keypress, event)
      end

      # Inspect class name and public attributes
      # @return [String]
      #
      # @api public
      def inspect
        "#<#{self.class}: @input=#{input}, @output=#{output}>"
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

      # Check if Windowz
      #
      # @return [Boolean]
      #
      # @api public
      def windows?
        !/mswin|mingw/.match(RbConfig::CONFIG["arch"]).nil?
      end
    end # Reader
  end # Prompt
end # TTY
