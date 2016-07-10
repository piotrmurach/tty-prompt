# encoding: utf-8

module TTY
  class Prompt
    class Reader
      class Mode
        # Initialize a Terminal
        #
        # @api public
        def initialize(options = {})
          @input = $stdin
        end

        # Echo given block
        #
        # @param [Boolean] is_on
        #
        # @api public
        def echo(is_on = true, &block)
          previous = @input.echo?
          @input.echo = is_on
          yield
        ensure
          @input.echo = previous
        end

        # Use raw mode in the given block
        #
        # @param [Boolean] is_on
        #
        # @api public
        def raw(is_on = true, &block)
          if is_on
            @input.raw(&block)
          else
            yield
          end
        end
      end # Mode
    end # Reader
  end # Prompt
end # TTY
