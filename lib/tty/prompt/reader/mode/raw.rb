# encoding: utf-8
require "io/console"

module TTY
  class Prompt
    class Reader
      class Mode
        # A class responsible for toggling raw mode.
        class Raw
          # Turn raw mode on
          #
          # @api public
          def on
            $stdin.raw = true
          end

          # Turn raw mode off
          #
          # @api public
          def off
            $stdin.raw = false
          end

          # Wrap code block inside raw mode
          #
          # @api public
          def raw(is_on=true, &block)
            value = nil
            on if is_on
            value = block.call if block_given?
          rescue NoMethodError, Interrupt => error
            puts "#{error.class} #{error.message}"
            puts error.backtrace
            off
            exit
          ensure
            off
            value
          end
        end # Raw
      end # Mode
    end # Reader
  end # Prompt
end # TTY
