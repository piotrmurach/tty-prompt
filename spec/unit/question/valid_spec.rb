# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#valid' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:prompt) { TTY::Prompt.new(input, output) }

  let(:cards) { %w[ club diamond spade heart ] }

  it 'reads valid optios with helper' do
    input << 'club'
    input.rewind
    q = prompt.ask("What is your card suit sir?").valid(cards)
    expect(q.read_choice).to eq('club')
  end

  it 'reads valid options with option hash' do
    input << 'club'
    input.rewind
    q = prompt.ask("What is your card suit sir?", valid: cards)
    expect(q.read_choice).to eq('club')
  end

  it 'reads invalid option' do
    input << 'clover'
    input.rewind
    q = prompt.ask("What is your card suit sir?").valid(cards)
    expect { q.read_choice }.to raise_error(TTY::Prompt::InvalidArgument)
  end

  it 'needs argument' do
    input << ''
    input.rewind
    q = prompt.ask("What is your card suit sir?").valid(cards)
    expect { q.read_choice }.to raise_error(TTY::Prompt::ArgumentRequired)
  end

  it 'reads with default' do
    input << ''
    input.rewind
    q = prompt.ask("What is your card suit sir?").valid(cards).default('club')
    expect(q.read_choice).to eq('club')
  end
end
