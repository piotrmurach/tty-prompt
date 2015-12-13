# encoding: utf-8

module TTY
  # A class responsible for terminal prompt interactions
  class Prompt

    # A class responsible for reading an answer
    class Response
      # Read answer provided on multiple lines
      #
      # @api public
      def read_multiline
        response = ''
        raw_input = ''
        loop do
          raw_input, value = evaluate_response
          break if !value || value == ''
          next  if value !~ /\S/
          response << value
        end
        [raw_input, response]
      end
    end # Response
  end # Prompt
end # TTY
