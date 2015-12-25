# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert char' do
  it 'reads single character' do
    prompt = TTY::TestPrompt.new
    prompt.input << "abcde"
    prompt.input.rewind
    response = prompt.ask("What is your favourite letter?", convert: :char)
    expect(response).to eq('a')
  end
end
