# encoding: utf-8

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
        @mask        = options.fetch(:mask) { Symbols::ITEM_SECURE }
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
          end
          header += masked
        end
        @prompt.print(header)
        @prompt.print("\n") if @done
      end

      def render_error_or_finish(result)
        @failure = result.failure?
        super
      end

      # Read input from user masked by character
      #
      # @private
      def read_input
        @done_masked = false
        @input = ''
        until @done_masked
          @prompt.read_keypress(echo?)
          @prompt.print(@prompt.clear_line)
          render_question
        end
        @prompt.print("\n")
        @input
      end
    end # MaskQuestion
  end # Prompt
end # TTY
