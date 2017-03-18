# encoding: utf-8

require 'wisper'
require 'rbconfig'

require_relative 'reader/history'
require_relative 'reader/line'
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

      attr_reader :track_history
      alias track_history? track_history

      attr_reader :console

      # Key codes
      CARRIAGE_RETURN = 13
      NEWLINE         = 10
      BACKSPACE       = 127
      DELETE          = 8

      # Initialize a Reader
      #
      # @param [IO] input
      #   the input stream
      # @param [IO] output
      #   the output stream
      # @param [Hash] options
      # @option options [Symbol] :interrupt
      #   handling of Ctrl+C key out of :signal, :exit, :noop
      # @option options [Boolean] :track_history
      #   disable line history tracking, true by default
      #
      # @api public
      def initialize(input = $stdin, output = $stdout, options = {})
        @input     = input
        @output    = output
        @interrupt = options.fetch(:interrupt) { :error }
        @env       = options.fetch(:env) { ENV }
        @track_history = options.fetch(:track_history) { true }
        @console   = select_console(input)
        @history   = History.new do |h|
          h.duplicates = false
          h.exclude = proc { |line| line.strip == '' }
        end
        @stop = false # gathering input

        subscribe(self)
      end

      # Select appropriate console
      #
      # @api private
      def select_console(input)
        if windows? && !env['TTY_TEST']
          WinConsole.new(input)
        else
          Console.new(input)
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
        handle_interrupt if char == console.keys[:ctrl_c]
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
        char = console.get_char(opts)
        return if char.nil?
        codes << char.ord

        condition = proc { |escape|
          (codes - escape).empty? ||
          (escape - codes).empty? &&
          !(64..126).include?(codes.last)
        }

        while console.escape_codes.any?(&condition)
          get_codes(options, codes)
        end
        codes
      end

      # Get a single line from STDIN. Each key pressed is echoed
      # back to the shell. The input terminates when enter or
      # return key is pressed.
      #
      # @param [String] prompt
      #   the prompt to display before input
      #
      # @param [Boolean] echo
      #   if true echo back characters, output nothing otherwise
      #
      # @return [String]
      #
      # @api public
      def read_line(*args)
        options = args.last.respond_to?(:to_hash) ? args.pop : {}
        prompt = args.empty? ? '' : args.pop
        opts = { echo: true, raw: true }.merge(options)
        line = Line.new('')
        ctrls = console.keys.keys.grep(/ctrl/)
        clear_line = "\e[2K\e[1G"

        while (codes = unbufferred { get_codes(opts) }) && (code = codes[0])
          char = codes.pack('U*')
          trigger_key_event(char)

          if console.keys[:backspace] == char || BACKSPACE == code
            next if line.start?
            line.left
            line.delete
          elsif console.keys[:delete] == char || DELETE == code
            line.delete
          elsif [console.keys[:ctrl_d],
                 console.keys[:ctrl_z]].include?(char)
            break
          elsif console.keys[:ctrl_c] == char
            handle_interrupt
          elsif ctrls.include?(console.keys.key(char))
            # skip
          elsif console.keys[:up] == char
            next unless history_previous?
            line.replace(history_previous)
          elsif console.keys[:down] == char
            line.replace(history_next? ? history_next : '')
          elsif console.keys[:left] == char
            line.left
          elsif console.keys[:right] == char
            line.right
          else
            if opts[:raw] && code == CARRIAGE_RETURN
              char = "\n"
              line.move_to_end
            end
            line.insert(char)
          end

          if opts[:raw] && opts[:echo]
            output.print(clear_line)
            output.print(prompt + line.to_s)
            if char == "\n"
              line.move_to_start
            elsif !line.end?
              output.print("\e[#{line.size - line.cursor}D")
            end
          end

          break if (code == CARRIAGE_RETURN || code == NEWLINE)

          if (console.keys[:backspace] == char || BACKSPACE == code) && opts[:echo]
            if opts[:raw]
              output.print("\e[1X") unless line.start?
            else
              output.print(?\s + (line.start? ? '' :  ?\b))
            end
          end
        end
        add_to_history(line.to_s.rstrip) if track_history?
        line.to_s
      end

      # Read multiple lines and return them in an array.
      # Skip empty lines in the returned lines array.
      # The input gathering is terminated by Ctrl+d or Ctrl+z.
      #
      # @param [String] prompt
      #   the prompt displayed before the input
      #
      # @yield [String] line
      #
      # @return [Array[String]]
      #
      # @api public
      def read_multiline(prompt = '')
        @stop = false
        lines = []
        loop do
          line = read_line(prompt)
          break if !line || line == ''
          next  if line !~ /\S/ && !@stop
          if block_given?
            yield(line) unless line.to_s.empty?
          else
            lines << line unless line.to_s.empty?
          end
          break if @stop
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

      # Capture Ctrl+d and Ctrl+z key events
      #
      # @api private
      def keyctrl_d(*)
        @stop = true
      end
      alias keyctrl_z keyctrl_d

      def add_to_history(line)
        @history.push(line)
      end

      def history_next?
        @history.next?
      end

      def history_next
        @history.next
        @history.get
      end

      def history_previous?
        @history.previous?
      end

      def history_previous
        line = @history.get
        @history.previous
        line
      end

      # Inspect class name and public attributes
      # @return [String]
      #
      # @api public
      def inspect
        "#<#{self.class}: @input=#{input}, @output=#{output}>"
      end

      private

      # Publish event
      #
      # @param [String] char
      #   the key pressed
      #
      # @return [nil]
      #
      # @api private
      def trigger_key_event(char)
        event = KeyEvent.from(console.keys, char)
        trigger(:"key#{event.key.name}", event) if event.trigger?
        trigger(:keypress, event)
      end

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
        ::File::ALT_SEPARATOR == "\\"
      end
    end # Reader
  end # Prompt
end # TTY
