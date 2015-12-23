# encoding: utf-8

require 'tty/prompt/reader/codes'
require 'wisper'

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
        mask = false if not_set
        value = ''
        buffer do
          begin
            while (char = input.getbyte) &&
                !(char == CARRIAGE_RETURN || char == NEWLINE)
              publish_keypress_event(convert_byte(char))
              value = handle_char(value, char, mask, echo)
            end
          ensure
            mode.echo_on
          end
        end
        value
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
        event = create_key_event(char)
        event_name = parse_key_event(event)
        publish(event_name, event) unless event_name.nil?
        publish(:keypress, event)
      end

      class Key < Struct.new(:name, :ctrl, :meta, :shift)
        def initialize(*)
          super
          @ctrl = false
          @meta = false
          @shift = false
        end
      end

      class KeyEvent < Struct.new(:value, :key)
      end

      META_KEY_CODE_RE = /^(?:\x1b+)(O|N|\[|\[\[)(?:(\d+)(?:;(\d+))?([~^$])|(?:1;)?(\d+)?([a-zA-Z]))/

      def create_key_event(char)
        key = Key.new
        case char
        when Codes::RETURN
          key.name = :return
        when Codes::LINEFEED
          key.name = :enter
        when Codes::TAB
          key.name = :tab
        when Codes::BACKSPACE
          key.name = :backspace
        when Codes::SPACE
          key.name = :space
        when Codes::CTRL_C, Codes::ESCAPE
          key.name = :escape
        when proc { |char| char <= "\x1a" }
          codes = char.each_codepoint.to_a
          key.name = "#{codes}"
          key.ctrl = true
        when /\d/
          key.name = :num
        when META_KEY_CODE_RE
          key.meta = true
          case char
          when Codes::KEY_UP, Codes::CTRL_K, Codes::CTRL_P
            key.name = :up
          when Codes::KEY_DOWN, Codes::CTRL_J, Codes::CTRL_N
            key.name = :down
          when Codes::KEY_RIGHT, Codes::CTRL_L
            key.name = :right
          when Codes::KEY_LEFT, Codes::CTRL_H
            key.name = :left
          end
        end
        KeyEvent.new(char, key)
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

      # Get a value from STDIN using line input.
      #
      # @api public
      def gets
        input.gets
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
      def handle_char(input, char, mask, echo)
        if char == BACKSPACE || char == DELETE
          input.slice!(-1, 1) unless input.empty?
        else
          print_char(char, mask) if echo
          input << char
        end
        input
      end

      # Print out character back to shell STDOUT
      #
      # @api private
      def print_char(char, mask)
        output.putc((mask != false) ? mask : char)
      end
    end # Reader
  end # Prompt
end # TTY
