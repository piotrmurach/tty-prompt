# encoding: utf-8

require 'tty/prompt'

module TTY
  # Used for initializing test cases
  class TestPrompt < Prompt
    def initialize(options = {})
      @input  = StringIO.new
      @output = StringIO.new
      options.merge!({input: @input, output: @output})
      super(options)
      @pastel = Pastel.new(enabled: true)
    end
  end # TestPrompt
end # TTY
