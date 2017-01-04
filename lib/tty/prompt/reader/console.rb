# encoding: utf-8

require 'tty/prompt/reader/mode'

module TTY
  class Prompt
    class Reader
      class Console

        def initialize(input)
          @input = input
          @mode  = Mode.new
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

        private

        attr_reader :mode

        attr_reader :input

      end # Console
    end # Reader
  end # Prompt
end # TTY
