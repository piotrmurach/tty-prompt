# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt, '#say' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:color)  { Pastel.new(enabled: true) }

  subject(:prompt) { described_class.new(input, output) }

  before { allow(Pastel).to receive(:new).and_return(color) }

  after { output.rewind }

  it 'prints an empty message' do
    prompt.say ""
    expect(output.string).to eql ""
  end

  context 'with new line' do
    it 'prints a message with newline' do
      prompt.say "Hell yeah!\n"
      expect(output.string).to eql "Hell yeah!\n"
    end

    it 'prints a message with implicit newline' do
      prompt.say "Hell yeah!\n"
      expect(output.string).to eql "Hell yeah!\n"
    end

    it 'prints a message with newline within text' do
      prompt.say "Hell\n yeah!"
      expect(output.string).to eql "Hell\n yeah!\n"
    end

    it 'prints a message with newline within text and blank space' do
      prompt.say "Hell\n yeah! "
      expect(output.string).to eql "Hell\n yeah! "
    end

    it 'prints a message without newline' do
      prompt.say "Hell yeah!", newline: false
      expect(output.string).to eql "Hell yeah!"
    end
  end

  context 'with tab or space' do
    it 'prints ' do
      prompt.say "Hell yeah!\t"
      expect(output.string).to eql "Hell yeah!\t"
    end
  end

  context 'with color' do
    it 'prints message with ansi color' do
      prompt.say "Hell yeah!", color: :green
      expect(output.string).to eql "\e[32mHell yeah!\e[0m\n"
    end

    it 'prints message with ansi color without newline' do
      prompt.say "Hell yeah! ", color: :green
      expect(output.string).to eql "\e[32mHell yeah! \e[0m"
    end
  end
end
