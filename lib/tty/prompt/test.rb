# frozen_string_literal: true

require "stringio"

require_relative "../prompt"

module TTY
  # Used for initializing test cases
  class Prompt
    class Test < TTY::Prompt
      def initialize(**options)
        @input  = StringIO.new
        @output = StringIO.new
        options.merge!({
          input: @input,
          output: @output,
          env: { "TTY_TEST" => true },
          enable_color: options.fetch(:enable_color) { true }
        })
        super(**options)
      end
    end # Test
  end # Prompt
end # TTY
