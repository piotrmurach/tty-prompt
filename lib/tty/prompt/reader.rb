# encoding: utf-8

require 'wisper'
require 'rbconfig'

require_relative 'reader/history'
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
        @history   = History.new do |h|
          h.duplicates = false
          h.exclude = proc { |line| line.strip == '' }
        end
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
        ctrls = @console.keys.keys.grep(/ctrl/)

        while (codes = get_codes(opts)) && (code = codes[0])
          char = codes.pack('U*')
          trigger_key_event(char)

          #puts "code: #{codes}"

          if delete_char[code]
            line.slice!(-1, 1)
            backspaces -= 1
          elsif ctrls.include?(@console.keys.key(char))
            # skip
          elsif @console.keys[:up] == char
            line = history_previous
          elsif @console.keys[:down] == char
            line = history_next
          else
            line << char
            line << "\n" if opts[:raw] && code == CARRIAGE_RETURN
            backspaces = line.size
          end

          break if (code == CARRIAGE_RETURN || code == NEWLINE || code == 4)

          if delete_char[code] && opts[:echo]
            output.print(' ' + (backspaces >= 0 ? "\b" : ''))
          end
        end
        add_to_history(line)
        line
      end

      def add_to_history(line)
        @history.push(line)
      end

      def history_next
        @history.next
      end

      def history_previous
        @history.previous
      end

      # Read multiple lines and return them in an array.
      # Lines are separated by separator, by default new line char.
      # Skip empty lines in the returned lines array.
      #
      # @yield [String] line
      #
      # @return [Array[String]]
      #
      # @api public
      def read_multiline
        lines = []
        loop do
          line = read_line({raw: true})
          break if !line || line == '' #|| line == "\n"
          next  if line !~ /\S/
          if block_given?
            yield(line)
          else
            lines << line
          end
        end
        lines
      end
      alias read_lines read_multiline

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
        return false if env["TTY_TEST"] == true
        ::File::ALT_SEPARATOR == "\\"
      end
    end # Reader
  end # Prompt
end # TTY
