# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#in' do
  it 'reads number within range' do
    prompt = TTY::TestPrompt.new
    prompt.input << 8
    prompt.input.rewind
    answer = prompt.ask("How do you like it on scale 1-10", read: :int) { |q|
      q.in('1-10')
    }
    expect(answer).to eq(8)
  end

  it "reads number outside of range" do
    prompt = TTY::TestPrompt.new
    prompt.input << 12
    prompt.input.rewind
    expect {
      prompt.ask("How do you like it on scale 1-10", read: :int) { |q|
        q.in('1-10')
      }
    }.to raise_error(ArgumentError)
  end
end
