# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#default' do
  it 'uses default value' do
    prompt = TTY::TestPrompt.new
    name = 'Anonymous'
    answer = prompt.ask('What is your name?', default: name)
    expect(answer).to eq(name)
    expect(prompt.output.string).to eq('What is your name? (Anonymous) ')
  end

  it 'uses default value in block' do
    prompt = TTY::TestPrompt.new
    name = 'Anonymous'
    answer = prompt.ask('What is your name?') { |q| q.default(name) }
    expect(answer).to eq(name)
    expect(prompt.output.string).to eq('What is your name? (Anonymous) ')
  end
end
