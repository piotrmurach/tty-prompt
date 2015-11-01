# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt, '#ask' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:prefix) { '' }
  let(:options) { { prefix: prefix } }

  subject(:prompt) { TTY::Prompt.new(input, output, options) }

  it 'prints message' do
    prompt.ask "What is your name?"
    expect(output.string).to eql "What is your name?\n"
  end

  it 'prints an empty message ' do
    prompt.ask ""
    expect(output.string).to eql ""
  end

  it 'prints an empty message and returns nil if EOF is sent to stdin' do
    input << nil
    input.rewind
    q = prompt.ask ""
    expect(q.read).to eql nil
  end

  context 'with a prompt prefix' do
    let(:prefix) { ' > ' }

    it "asks a question with '>'" do
      input << ''
      input.rewind
      prompt.ask "Are you Polish?"
      expect(output.string).to eql " > Are you Polish?\n"
    end
  end

  it 'asks a question with block' do
    input << ''
    input.rewind
    q = prompt.ask "What is your name?" do
      default 'Piotr'
    end
    expect(q.read).to eql "Piotr"
  end

  context 'yes?' do
    it 'agrees' do
      input << 'yes'
      input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(true)
    end

    it 'disagrees' do
      input << 'no'
      input.rewind
      expect(prompt.yes?("Are you a human?")).to eq(false)
    end
  end

  context 'no?' do
    it 'agrees' do
      input << 'no'
      input.rewind
      expect(prompt.no?("Are you a human?")).to eq(true)
    end

    it 'disagrees' do
      input << 'yes'
      input.rewind
      expect(prompt.no?("Are you a human?")).to eq(false)
    end
  end
end
