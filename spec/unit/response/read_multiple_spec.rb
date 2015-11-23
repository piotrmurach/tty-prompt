# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#read_multiline' do
  it 'reads multiple lines' do
    prompt = TTY::TestPrompt.new
    prompt.input << "First line\nSecond line\nThird line"
    prompt.input.rewind
    answer = prompt.ask("Provide description?", read: :multiline)
    expect(answer).to eq("First line\nSecond line\nThird line")
  end

  it 'terminates on empty lines' do
    prompt = TTY::TestPrompt.new
    prompt.input << "First line\n\nSecond line"
    prompt.input.rewind
    answer = prompt.ask("Provide description?")
    expect(answer).to eq("First line\n")
  end
end
