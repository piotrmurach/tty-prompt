# encoding: utf-8

require 'timeout'

require_relative 'question'
require_relative 'symbols'

module TTY
  class Prompt
    class Keypress < Question
      # Create keypress question
      #
      # @param [Prompt] prompt
      # @param [Hash] options
      #
      # @api public
      def initialize(prompt, options = {})
        super
        @echo    = options.fetch(:echo) { false }
        @keys    = options.fetch(:keys) { UndefinedSetting }
        @timeout = options.fetch(:timeout) { UndefinedSetting }
        @pause   = true

        @prompt.subscribe(self)
      end

      # Check if any specific keys are set
      def any_key?
        @keys == UndefinedSetting
      end

      # Check if timeout is set
      def timeout?
        @timeout != UndefinedSetting
      end

      def keypress(event)
        if any_key?
          @pause = false
        elsif @keys.is_a?(Array) && @keys.include?(event.key.name)
          @pause = false
        else
          @pause = true
        end
      end

      def process_input(question)
        time do
          while @pause
            question[-1] = 'try'
            @input = @prompt.read_keypress
          end
        end
        @evaluator.(@input)
      end

      def refresh(lines)
        @prompt.clear_line
      end

      def time(&block)
        if timeout?
          secs = Integer(@timeout)
          Timeout::timeout(secs, &block)
        else
          block.()
        end
      rescue Timeout::Error
      end
    end # Keypress
  end # Prompt
end # TTY
