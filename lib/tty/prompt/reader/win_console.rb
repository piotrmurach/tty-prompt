# encoding: utf-8

require 'tty/prompt/reader/codes'

module TTY
  class Prompt
    class Reader
      class WinConsole
        ESC = "\e".freeze

        def initialize
          require 'tty/prompt/reader/windows_api'
        end

        # Escape codes
        #
        # @return [Array[Integer]]
        #
        # @api public
        def escape_codes
          [[0], [ESC.ord], [224]]
        end

        # Key codes
        #
        # @return [Hash[Symbol]]
        #
        # @api public
        def keys
          Codes.win_keys
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
          options[:echo] ? WindowsAPI.getche : WindowsAPI.getch
        end
      end # Console
    end # Reader
  end # Prompt
end # TTY
