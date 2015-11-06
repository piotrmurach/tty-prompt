# encoding: utf-8

module TTY
  class Prompt
    class Mode
      # A class responsible for toggling echo.
      class Echo
        # Turn echo on
        #
        # @api public
        def on
          %x{stty echo} if TTY::Platform.unix?
        end

        # Turn echo off
        #
        # @api public
        def off
          %x{stty -echo} if TTY::Platform.unix?
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
          return value
        end
      end # Echo
    end # Mode
  end # Prompt
end # TTY
