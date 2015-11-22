# encoding: utf-8

module TTY
  # A class responsible for shell prompt interactions.
  class Prompt
    # A class representing a statement output to prompt.
    class Statement
      # @api private
      attr_reader :prompt
      private :prompt

      # Flag to display newline
      #
      # @api public
      attr_reader :newline

      # Color used to display statement
      #
      # @api public
      attr_reader :color

      # Initialize a Statement
      #
      # @param [TTY::Prompt] prompt
      #
      # @param [Hash] options
      #
      # @option options [Symbol] :newline
      #   force a newline break after the message
      #
      # @option options [Symbol] :color
      #   change the message display to color
      #
      # @api public
      def initialize(prompt = Prompt.new, options = {})
        @prompt   = prompt
        @pastel  = Pastel.new
        @newline = options.fetch(:newline, true)
        @color   = options.fetch(:color, false)
      end

      # Output the message to the prompt
      #
      # @param [String] message
      #   the message to be printed to stdout
      #
      # @api public
      def declare(message)
        message = @pastel.decorate message, *color if color

        if newline && /( |\t)(\e\[\d+(;\d+)*m)?\Z/ !~ message
          prompt.output.puts message
        else
          prompt.output.print message
          prompt.output.flush
        end
      end
    end # Statement
  end # Prompt
end # TTY
