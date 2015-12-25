# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#in' do

  subject(:prompt) { TTY::TestPrompt.new }

  it 'reads number within string range' do
    prompt.input << '8'
    prompt.input.rewind
    answer = prompt.ask("How do you like it on scale 1-10?", convert: :int) do |q|
      q.in('1-10')
    end
    expect(answer).to eq(8)
    expect(prompt.output.string).to eq([
      "How do you like it on scale 1-10? 8",
      "\e[1A\e[1000D\e[K",
      "How do you like it on scale 1-10? \e[32m8\e[0m",
    ].join)
  end

  it 'reads number within string range' do
    prompt.input << '8'
    prompt.input.rewind
    answer = prompt.ask("How do you like it on scale 1-10?", convert: :int) do |q|
      q.in(1..10)
    end
    expect(answer).to eq(8)
    expect(prompt.output.string).to eq([
      "How do you like it on scale 1-10? 8",
      "\e[1A\e[1000D\e[K",
      "How do you like it on scale 1-10? \e[32m8\e[0m",
    ].join)
  end
end
