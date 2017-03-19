# encoding: utf-8

require_relative 'question'
require_relative 'symbols'
require_relative 'timeout'

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
        @interval = options.fetch(:interval) { 1 }
        @pause   = true
        @countdown = @timeout
        @interval_handler = proc { |time|
          question = render_question
          @prompt.print(refresh(question.lines.count))
          countdown(time)
          @prompt.print(render_question)
        }

        @prompt.subscribe(self)
      end

      def countdown(value = (not_set = true))
        return @countdown if not_set
        @countdown = value
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

      def render_question
        header = super
        header.gsub!(/:countdown/, countdown.to_s)
        header
      end

      def process_input(question)
        time do
          while @pause
            @input = @prompt.read_keypress
          end
        end
        @evaluator.(@input)
      end

      def refresh(lines)
        @prompt.clear_lines(lines)
      end

      def time(&block)
        if timeout?
          secs = Integer(@timeout)
          interval = Integer(@interval)
          scheduler = Timeout.new(interval_handler: @interval_handler)
          scheduler.timeout(secs, interval, &block)
        else
          block.()
        end
      rescue Timeout::Error
      end
    end # Keypress
  end # Prompt
end # TTY
