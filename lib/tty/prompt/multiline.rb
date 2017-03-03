# encoding: utf-8

require_relative 'question'
require_relative 'symbols'

module TTY
  class Prompt
    class Multiline < Question
      def read_input
        @prompt.read_multiline.each(&:chomp!)
      end
    end # Multiline
  end # Prompt
end # TTY
