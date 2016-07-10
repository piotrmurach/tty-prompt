# encoding: utf-8
require "io/console"

module TTY
  class Prompt
    class Reader
      class Mode
        # A class responsible for toggling echo.
        class Echo
          # Turn echo on
          #
          # @api public
          def on
            $stdin.echo = true
          end

          # Turn echo off
          #
          # @api public
          def off
            $stdin.echo = false
          end

          # Wrap code block inside echo
          #
          # @api public
          def echo(is_on=true, &block)
            value = nil
            off unless is_on
            value = block.call if block_given?
          rescue NoMethodError, Interrupt => error
            puts "#{error.class} #{error.message}"
            puts error.backtrace
            on
            exit
          ensure
            on
            value
          end
        end # Echo
      end # Mode
    end # Reader
  end # Prompt
end # TTY
