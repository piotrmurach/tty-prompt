# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#valid' do
  let(:cards) { %w[ club diamond spade heart ] }

  it 'reads valid optios with helper' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'club'
    prompt.input.rewind
    answer = prompt.ask('What is your card suit sir?') { |q|
      q.valid(cards)
    }
    expect(answer).to eq('club')
  end

  it 'reads valid options with option hash' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'club'
    prompt.input.rewind
    answer = prompt.ask('What is your card suit sir?', valid: cards)
    expect(answer).to eq('club')
  end

  it 'reads invalid option' do
    prompt = TTY::TestPrompt.new
    prompt.input << 'clover'
    prompt.input.rewind
    expect {
      prompt.ask('What is your card suit sir?', valid: cards)
    }.to raise_error(TTY::Prompt::InvalidArgument)
  end

  it 'reads no input' do
    prompt = TTY::TestPrompt.new
    prompt.input << ''
    prompt.input.rewind
    answer = prompt.ask('What is your card suit sir?') { |q| q.valid(cards) }
    expect(answer).to eq(nil)
  end

  it 'reads with default' do
    prompt = TTY::TestPrompt.new
    prompt.input << ''
    prompt.input.rewind
    answer = prompt.ask('What is your card suit sir?') { |q|
      q.valid(cards)
      q.default('club')
    }
    expect(answer).to eq('club')
  end
end
