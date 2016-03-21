# encoding: utf-8

module TTY
  class Prompt
    class AnswersCollector
      # Initialize answer collector
      #
      # @api public
      def initialize(prompt, options = {})
        @prompt  = prompt
        @answers = options.fetch(:answers) { {} }
      end

      # Start gathering answers
      #
      # @return [Hash]
      #   the collection of all answers
      #
      # @api public
      def call(&block)
        instance_eval(&block)
        @answers
      end

      # Create answer entry
      #
      # @example
      #   key(:name).ask('Name?')
      #
      # @api public
      def key(name, &block)
        @name = name
        if block
          answer = create_collector.(&block)
          add_answer(answer)
        end
        self
      end

      # @api public
      def create_collector
        self.class.new(@prompt)
      end

      # @api public
      def add_answer(answer)
        @answers[@name] = answer
      end

      private

      # @api private
      def method_missing(method, *args, &block)
        answer = @prompt.public_send(method, *args, &block)
        add_answer(answer)
      end
    end # AnswersCollector
  end # Prompt
end # TTY
