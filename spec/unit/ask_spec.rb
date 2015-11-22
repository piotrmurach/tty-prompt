# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt, '#ask' do
  let(:prefix) { '' }
  let(:options) { { prefix: prefix } }

  subject(:prompt) { TTY::TestPrompt.new(options) }

  it 'prints message' do
    prompt.ask("What is your name?")
    expect(prompt.output.string).to eql("What is your name?")
  end

  it 'prints an empty message ' do
    prompt.ask ""
    expect(prompt.output.string).to eql ""
  end

  it 'prints an empty message and returns nil if EOF is sent to stdin' do
    prompt.input << nil
    prompt.input.rewind
    q = prompt.ask ""
    expect(q.read).to eql nil
  end

  context 'with a prompt prefix' do
    let(:prefix) { ' > ' }

    it "asks a question with '>'" do
      prompt.input << ''
      prompt.input.rewind
      prompt.ask "Are you Polish?"
      expect(prompt.output.string).to eql " > Are you Polish?"
    end
  end

  it 'asks a question with block' do
    prompt.input << ''
    prompt.input.rewind
    question = prompt.ask "What is your name?" do |q|
      q.default 'Piotr'
    end
    expect(question.read).to eql "Piotr"
  end

  context 'yes?' do
    it 'agrees' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(true)
    end

    it 'disagrees' do
      prompt.input << 'no'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(false)
    end
  end

  context 'no?' do
    it 'agrees' do
      prompt.input << 'no'
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(true)
    end

    it 'disagrees' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.no?("Are you a human?")).to eq(false)
    end
  end
end
