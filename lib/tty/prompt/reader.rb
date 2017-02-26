# encoding: utf-8

require 'wisper'
require 'rbconfig'

require_relative 'reader/key_event'
require_relative 'reader/console'
require_relative 'reader/win_console'

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

      attr_reader :env

      # Key codes
      CARRIAGE_RETURN = 13
      NEWLINE         = 10
      BACKSPACE       = 127
      DELETE          = 8

      # Initialize a Reader
      #
      # @api public
      def initialize(input = $stdin, output = $stdout, options = {})
        @input     = input
        @output    = output
        @interrupt = options.fetch(:interrupt) { :error }
        @env       = options.fetch(:env) { ENV }
        @console   = windows? ? WinConsole.new(input) : Console.new(input)
      end

      # Get input in unbuffered mode.
      #
      # @example
      #   unbufferred do
      #     ...
      #   end
      #
      # @api public
      def unbufferred(&block)
        bufferring = output.sync
        # Immediately flush output
        output.sync = true
        block[] if block_given?
      ensure
        output.sync = bufferring
      end

      # Read a keypress  including invisible multibyte codes
      # and return a character as a string.
      # Nothing is echoed to the console. This call will block for a
      # single keypress, but will not wait for Enter to be pressed.
      #
      # @param [Hash[Symbol]] options
      # @option options [Boolean] echo
      #   whether to echo chars back or not, defaults to false
      # @option options [Boolean] raw
      #   whenther raw mode enabled, defaults to true
      #
      # @return [String]
      #
      # @api public
      def read_keypress(options = {})
        opts  = { echo: false, raw: true }.merge(options)
        codes = unbufferred { get_codes(opts) }
        char  = codes ? codes.pack('U*') : nil

        trigger_key_event(char) if char
        handle_interrupt if char == @console.keys[:ctrl_c]
        char
      end
      alias read_char read_keypress

      # Get input code points
      #
      # @param [Hash[Symbol]] options
      # @param [Array[Integer]] codes
      #
      # @return [Array[Integer]]
      #
      # @api private
      def get_codes(options = {}, codes = [])
        opts = { echo: true, raw: false }.merge(options)
        char = @console.get_char(opts)
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
        backspaces = 0
        delete_char = proc { |c| c == BACKSPACE || c == DELETE }

        while (codes = get_codes(opts)) && (code = codes[0])
          char = codes.pack('U*')
          trigger_key_event(char)

          if delete_char[code]
            line.slice!(-1, 1)
            backspaces -= 1
          else
            line << char
            backspaces = line.size
          end

          break if (code == CARRIAGE_RETURN || code == NEWLINE)

          if delete_char[code] && opts[:echo]
            output.print(' ' + (backspaces >= 0 ? "\b" : ''))
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

      # Expose event broadcasting
      #
      # @api public
      def trigger(event, *args)
        publish(event, *args)
      end

      # Publish event
      #
      # @param [String] char
      #   the key pressed
      #
      # @return [nil]
      #
      # @api public
      def trigger_key_event(char)
        event = KeyEvent.from(@console.keys, char)
        trigger(:"key#{event.key.name}", event) if event.trigger?
        trigger(:keypress, event)
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

      # Check if Windowz mode
      #
      # @return [Boolean]
      #
      # @api public
      def windows?
        return false if env["TTY_TEST"] = "true"
        ::File::ALT_SEPARATOR == "\\"
      end
    end # Reader
  end # Prompt
end # TTY
