# encoding: utf-8

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
            %x{stty raw} rescue nil
          end

          # Turn raw mode off
          #
          # @api public
          def off
            %x{stty -raw} rescue nil
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
