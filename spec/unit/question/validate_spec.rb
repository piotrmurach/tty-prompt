# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#validate' do
  it 'fails to validate input' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'piotrmurach'
    prompt.input.rewind
    expect {
      prompt.ask('What is your username?') { |q|
        q.validate(/^[^\.]+\.[^\.]+/)
      }
    }.to raise_error(ArgumentError)
  end

  it 'validates input with regex' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'piotr.murach'
    prompt.input.rewind
    answer = prompt.ask('What is your username?') { |q|
      q.validate(/^[^\.]+\.[^\.]+/)
    }
    expect(answer).to eq('piotr.murach')
  end

  it 'validates input in block' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'piotr.murach'
    prompt.input.rewind
    answer = prompt.ask('What is your username?') { |q|
      q.validate { |arg| arg =~ /^[^\.]+\.[^\.]+/ }
    }
    expect(answer).to eq('piotr.murach')
  end
end
