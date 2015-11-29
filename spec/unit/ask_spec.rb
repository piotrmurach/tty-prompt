# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt, '#ask' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'prints message' do
    prompt.ask("What is your name?")
    expect(prompt.output.string).to eql("What is your name?")
  end

  it 'prints an empty message ' do
    prompt.ask('')
    expect(prompt.output.string).to eql('')
  end

  it 'prints an empty message and returns nil if EOF is sent to stdin' do
    prompt.input << nil
    prompt.input.rewind
    response = prompt.ask("")
    expect(response).to eql(nil)
    expect(prompt.output.string).to eq('')
  end

  it "asks a question with a prefix [?]" do
    prompt = TTY::TestPrompt.new(prefix: "[?] ")
    prompt.input << ''
    prompt.input.rewind
    response = prompt.ask "Are you Polish?"
    expect(response).to eq(nil)
    expect(prompt.output.string).to eql "[?] Are you Polish?"
  end

  it 'asks a question with block' do
    prompt.input << ''
    prompt.input.rewind
    value = prompt.ask "What is your name?" do |q|
      q.default 'Piotr'
    end
    expect(value).to eql "Piotr"
    expect(prompt.output.string).to eq('What is your name?')
  end

  context 'yes?' do
    it 'agrees' do
      prompt.input << 'yes'
      prompt.input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(true)
      expect(prompt.output.string).to eq('Are you a human?')
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
