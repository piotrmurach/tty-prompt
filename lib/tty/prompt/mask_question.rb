# encoding: utf-8

require_relative 'question'
require_relative 'symbols'

module TTY
  class Prompt
    class MaskQuestion < Question
      # Create masked question
      #
      # @param [Hash] options
      # @option options [String] :mask
      #
      # @api public
      def initialize(prompt, options = {})
        super
        @mask        = options.fetch(:mask) { Symbols.symbols[:dot] }
        @done_masked = false
        @failure     = false
        @prompt.subscribe(self)
      end

      # Set character for masking the STDIN input
      #
      # @param [String] char
      #
      # @return [self]
      #
      # @api public
      def mask(char = (not_set = true))
        return @mask if not_set
        @mask = char
      end

      def keyreturn(event)
        @done_masked = true
      end

      def keyenter(event)
        @done_masked = true
      end

      def keypress(event)
        if [:backspace, :delete].include?(event.key.name)
          @input.chop! unless @input.empty?
        elsif event.value =~ /^[^\e\n\r]/
          @input += event.value
        end
      end

      # Render question and input replaced with masked character
      #
      # @api private
      def render_question
        header = "#{@prefix}#{message} "
        if echo?
          masked = "#{@mask * "#{@input}".length}"
          if @done_masked && !@failure
            masked = @prompt.decorate(masked, @active_color)
          elsif @done_masked && @failure
            masked = @prompt.decorate(masked, @error_color)
          end
          header += masked
        end
        header << "\n" if @done
        header
      end

      def render_error(errors)
        @failure = !errors.empty?
        super
      end

      # Read input from user masked by character
      #
      # @private
      def read_input(question)
        @done_masked = false
        @failure = false
        @input = ''
        until @done_masked
          @prompt.read_keypress
          @prompt.print(@prompt.clear_line)
          @prompt.print(render_question)
        end
        @prompt.puts
        @input
      end
    end # MaskQuestion
  end # Prompt
end # TTY
