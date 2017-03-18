# encoding: utf-8

require_relative 'question'
require_relative 'symbols'

module TTY
  class Prompt
    class Keypress < Question

      def process_input(question)
        @input = @prompt.read_keypress
        @evaluator.(@input)
      end

      def refresh(lines)
        @prompt.clear_line
      end
    end # Keypress
  end # Prompt
end # TTY
