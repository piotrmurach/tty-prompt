# frozen_string_literal: true

RSpec.describe TTY::Prompt, '#warn' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'displays one message' do
    prompt.warn "Careful young apprentice!"
    expect(prompt.output.string).to eql "\e[33mCareful young apprentice!\e[0m\n"
  end

  it 'displays many messages' do
    prompt.warn "Careful there!", "It's dangerous!"
    expect(prompt.output.string).to eql "\e[33mCareful there!\e[0m\n\e[33mIt's dangerous!\e[0m\n"
  end

  it 'displays message with option' do
    prompt.warn "Careful young apprentice!", newline: false
    expect(prompt.output.string).to eql "\e[33mCareful young apprentice!\e[0m"
  end
end
