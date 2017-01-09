# encoding: utf-8

require 'tty/prompt/reader/codes'

module TTY
  class Prompt
    class Reader
      class WinConsole
        ESC     = "\e".freeze
        NUL_HEX = "\x00".freeze
        EXT_HEX = "\xE0".freeze

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

        def initialize
          require 'tty/prompt/reader/win_api'
          @keys = Codes.win_keys
          @escape_codes = [[NUL_HEX.ord], [ESC.ord], EXT_HEX.bytes.to_a]
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
          options[:echo] ? WinAPI.getche : WinAPI.getch
        end
      end # Console
    end # Reader
  end # Prompt
end # TTY
