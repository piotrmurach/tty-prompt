# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question, '#read_email' do
  context 'with valid email' do
    it 'reads empty' do
      prompt = TTY::TestPrompt.new
      prompt.input << ""
      prompt.input.rewind
      response = prompt.ask("What is your email?", read: :email)
      expect(response).to eql(nil)
    end

    it 'reads valid email' do
      prompt = TTY::TestPrompt.new
      prompt.input << "piotr@example.com"
      prompt.input.rewind
      response = prompt.ask('What is your email?', read: :email)
      expect(response).to eq('piotr@example.com')
    end
  end

  context 'with invalid email' do
    it 'fails to read invalid email' do
      prompt = TTY::TestPrompt.new
      prompt.input << "this will@neverwork"
      prompt.input.rewind
      expect {
        prompt.ask("What is your email?", read: :email)
      }.to raise_error(TTY::Prompt::InvalidArgument)
    end

    xit 'reads invalid and asks again' do
      prompt = TTY::TestPrompt.new
      prompt.input << "this will@neverwork\nthis.will@example.com"
      prompt.input.rewind
      response = prompt.ask("What is your email?", read: :email) do |q|
        q.on_error :retry
      end
      expect(response).to eq('this.will@example.com')
      expect(prompt.output.string).to eq("What is your email?\nWhat is your email?")
    end
  end
end
