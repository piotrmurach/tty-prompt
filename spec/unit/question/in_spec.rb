# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#in' do

  subject(:prompt) { TTY::TestPrompt.new }

  xit 'reads number within string range' do
    prompt.input << '8'
    prompt.input.rewind
    answer = prompt.ask("How do you like it on scale 1-10?") do |q|
      q.in('1-10')
    end
    expect(answer).to eq(8)
    expect(prompt.output.string).to eq([
      "How do you like it on scale 1-10? 8",
      "\e[1A\e[1000D\e[K",
      "How do you like it on scale 1-10? \e[32m8\e[0m",
    ].join)
  end

  xit 'reads number within string range' do
    prompt.input << '8'
    prompt.input.rewind
    answer = prompt.ask("How do you like it on scale 1-10?") do |q|
      q.in(1..10)
    end
    expect(answer).to eq(8)
    expect(prompt.output.string).to eq([
      "How do you like it on scale 1-10? 8",
      "\e[1A\e[1000D\e[K",
      "How do you like it on scale 1-10? \e[32m8\e[0m",
    ].join)
  end

  it 'reads letters within range' do
    prompt.input << 'E'
    prompt.input.rewind
    answer = prompt.ask("Your favourite vitamin? (A-K)") do |q|
      q.in('A-K')
    end
    expect(answer).to eq('E')
    expect(prompt.output.string).to eq([
      "Your favourite vitamin? (A-K) ",
      "\e[1A\e[1000D\e[K",
      "Your favourite vitamin? (A-K) \e[32mE\e[0m"
    ].join)
  end
end
