# encoding: utf-8

module TTY
  class Prompt
    class Reader
      class WinConsole

        def initialize
          require 'tty/prompt/reader/windows_api'
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
