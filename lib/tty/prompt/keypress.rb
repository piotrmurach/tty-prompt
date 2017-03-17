# encoding: utf-8

require_relative 'question'
require_relative 'symbols'

module TTY
  class Prompt
    class Keypress < Question
      def read_input
        @prompt.read_keypress
      end

      def refresh(lines)
        @prompt.clear_line
      end
    end # Keypress
  end # Prompt
end # TTY
