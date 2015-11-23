# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#read_char' do
  it 'reads single character' do
    prompt = TTY::TestPrompt.new
    prompt.input << "abcde"
    prompt.input.rewind
    response = prompt.ask("What is your favourite letter?", read: :char)
    expect(response).to eq('a')
  end
end
