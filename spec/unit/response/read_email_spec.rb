# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#read_email' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:prompt) { TTY::Prompt.new(input, output) }

  context 'with valid email' do
    it 'reads empty' do
      input << ""
      input.rewind
      q = prompt.ask("What is your email?")
      expect(q.read_email).to eql(nil)
    end

    it 'reads valid email' do
      input << "piotr@example.com"
      input.rewind
      q = prompt.ask("What is your email?")
      expect(q.read_email).to eql "piotr@example.com"
    end
  end

  context 'with invalid email' do
    it 'fails to read invalid email' do
      input << "this will@neverwork"
      input.rewind
      q = prompt.ask("What is your email?")
      expect { q.read_email }.to raise_error(TTY::Prompt::InvalidArgument)
    end

    it 'reads invalid and asks again' do
      input << "this will@neverwork\nthis.will@example.com"
      input.rewind
      q = prompt.ask("What is your email?").on_error(:retry)
      expect(q.read_email).to eql "this.will@example.com"
      expect(output.string).to eql "What is your email?\nWhat is your email?\n"
    end
  end
end
