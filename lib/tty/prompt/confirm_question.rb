# encoding: utf-8

module TTY
  class Prompt
    class ConfirmQuestion < Question
      # Create confirmation question
      #
      # @param [Hash] options
      # @option options [String] :suffix
      # @option options [String] :positive
      # @option options [String] :negative
      #
      # @api public
      def initialize(prompt, options = {})
        super
        @convert  = options.fetch(:convert)  { :bool }
        @suffix   = options.fetch(:suffix)   { 'Y/n' }
        @positive = options.fetch(:positive) { 'Yes' }
        @negative = options.fetch(:negative) { 'No' }
      end

      # Set question suffix
      #
      # @api public
      def suffix(value)
        @suffix = value
      end

      # Set value for matching positive choice
      #
      # @api public
      def positive(value)
        @positive = value
      end

      # Set value for matching negative choice
      #
      # @api public
      def negative(value)
        @negative = value
      end

      # Render confirmation question
      #
      # @api private
      def render_question
        header = "#{prompt.prefix}#{message} "

        if !@done
          header += @prompt.decorate("(#{@suffix})", :bright_black) + ' '
        else
          answer = convert_result(@input)
          label  = answer ? @positive : @negative
          header += @prompt.decorate(label, @color)
        end
        @prompt.print(header)
        @prompt.print("\n") if @done
      end
    end # ConfirmQuestion
  end # Prompt
end # TTY
