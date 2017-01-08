# encoding: utf-8

require 'tty/prompt/reader/codes'
require 'tty/prompt/reader/mode'

module TTY
  class Prompt
    class Reader
      class Console
        ESC = "\e".freeze
        CSI = "\e[".freeze

        attr_reader :mode

        attr_reader :input

        # Key codes
        #
        # @return [Hash[Symbol]]
        #
        # @api public
        attr_reader :keys

        # Escape codes
        #
        # @return [Array[Integer]]
        #
        # @api public
        attr_reader :escape_codes

        def initialize(input)
          @input = input
          @mode  = Mode.new
          @keys  = Codes.keys
          @escape_codes = [[ESC.ord], CSI.bytes.to_a]
        end

        # Get a character from console with echo
        #
        # @param [Hash[Symbol]] options
        # @option options [Symbol] :echo
        #   the echo toggle
        #
        # @return [String]
        #
        # @api private
        def get_char(options)
          mode.raw(options[:raw]) do
            mode.echo(options[:echo]) { input.getc }
          end
        end
      end # Console
    end # Reader
  end # Prompt
end # TTY
