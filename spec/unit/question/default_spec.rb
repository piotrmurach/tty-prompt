# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#default' do
  it 'uses default value' do
    prompt = TTY::TestPrompt.new
    name = 'Anonymous'
    q = prompt.ask("What is your name?").default(name)
    expect(q.read).to eq(name)
  end

  it 'uses default value in block' do
    prompt = TTY::TestPrompt.new
    name = 'Anonymous'
    question = prompt.ask "What is your name?" do |q|
      q.default name
    end
    expect(question.read).to eq(name)
  end
end
