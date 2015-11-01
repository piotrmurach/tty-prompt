# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#default' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:prompt) { TTY::Prompt.new(input, output) }

  it 'uses default value' do
    name = 'Anonymous'
    q = prompt.ask("What is your name?").default(name)
    answer = q.read
    expect(answer).to eq(name)
  end

  it 'uses default value in block' do
    name = 'Anonymous'
    q = prompt.ask "What is your name?" do
      default name
    end
    answer = q.read
    expect(answer).to eq(name)
  end
end
