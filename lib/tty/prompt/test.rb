# encoding: utf-8

require 'tty/prompt'

module TTY
  # Used for initializing test cases
  class TestPrompt < Prompt
    def initialize(options = {})
      @input  = StringIO.new
      @output = StringIO.new
      options.merge!({
        input: @input,
        output: @output,
        enable_color: options.fetch(:enable_color) { true }
      })
      super(options)
    end
  end # TestPrompt
end # TTY
