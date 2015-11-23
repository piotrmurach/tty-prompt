# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#default' do
  it 'uses default value' do
    prompt = TTY::TestPrompt.new
    name = 'Anonymous'
    answer = prompt.ask('What is your name?', default: name)
    expect(answer).to eq(name)
  end

  it 'uses default value in block' do
    prompt = TTY::TestPrompt.new
    name = 'Anonymous'
    answer = prompt.ask('What is your name?') { |q| q.default(name) }
    expect(answer).to eq(name)
  end
end
