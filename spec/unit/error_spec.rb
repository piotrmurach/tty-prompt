# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt, '.error' do
  let(:color)  { Pastel.new(enabled: true) }

  subject(:prompt) { TTY::TestPrompt.new }

  before { allow(Pastel).to receive(:new).and_return(color) }

  it 'displays one message' do
    prompt.error "Nothing is fine!"
    expect(prompt.output.string).to eql "\e[31mNothing is fine!\e[0m\n"
  end

  it 'displays many messages' do
    prompt.error "Nothing is fine!", "All is broken!"
    expect(prompt.output.string).to eql "\e[31mNothing is fine!\e[0m\n\e[31mAll is broken!\e[0m\n"
  end

  it 'displays message with option' do
    prompt.error "Nothing is fine!", newline: false
    expect(prompt.output.string).to eql "\e[31mNothing is fine!\e[0m"
  end
end
