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
        @mask = options.fetch(:mask) { Symbols::ITEM_SECURE }
        @done_masked = false
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
        header = "#{prompt.prefix}#{message} "
        if echo?
          masked = "#{@mask * "#{@input}".length}"
          if @done_masked
            masked = @prompt.decorate(masked, @color)
          end
          header += masked
        end
        @prompt.print(header)
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
        @prompt.print(@prompt.clear_line)
        @input
      end

      # Clear input line
      #
      # @api privatek
      def refresh_screen(errors = nil)
        @prompt.print(@prompt.clear_line)
      end

      def inspect
        "#<MaskedQuestion @message=#{message}>"
      end
    end # MaskQuestion
  end # Prompt
end # TTY
