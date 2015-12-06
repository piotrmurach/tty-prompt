# encoding: utf-8

require 'tty/prompt/result'

module TTY
  class Prompt
    # Evaluates provided parameters and stops if any of them fails
    # @api private
    class Evaluator
      def initialize(question, &block)
        @question = question
        @result = []
        instance_eval(&block) if block
      end

      def call(initial)
        seed = Result::Success.new(@question, initial)
        @result.reduce(seed, &:with)
      end

      def check(proc = nil, &block)
        @result << (proc || block)
      end
      alias_method :>=, :check

      def results
        @checks
      end
    end # Evaluator
  end # Prompt
end # TTY
