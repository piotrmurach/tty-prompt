# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#in' do

  subject(:prompt) { TTY::TestPrompt.new }

  it "reads range from option" do
    prompt.input << '8'
    prompt.input.rewind

    answer = prompt.ask("How do you like it on scale 1-10?", in: '1-10')

    expect(answer).to eq('8')
  end

  it 'reads number within string range' do
    prompt.input << '8'
    prompt.input.rewind

    answer = prompt.ask("How do you like it on scale 1-10?") do |q|
      q.in('1-10')
    end

    expect(answer).to eq('8')
    expect(prompt.output.string).to eq([
      "How do you like it on scale 1-10? ",
      "\e[2K\e[1GHow do you like it on scale 1-10? 8",
      "\e[1A\e[2K\e[1G",
      "How do you like it on scale 1-10? \e[32m8\e[0m\n",
    ].join)
  end

  it 'reads number within digit range' do
    prompt.input << '8.1'
    prompt.input.rewind

    answer = prompt.ask("How do you like it on scale 1-10?") do |q|
      q.in(1.0..11.5)
    end

    expect(answer).to eq('8.1')
    expect(prompt.output.string).to eq([
      "How do you like it on scale 1-10? ",
      "\e[2K\e[1GHow do you like it on scale 1-10? 8",
      "\e[2K\e[1GHow do you like it on scale 1-10? 8.",
      "\e[2K\e[1GHow do you like it on scale 1-10? 8.1",
      "\e[1A\e[2K\e[1G",
      "How do you like it on scale 1-10? \e[32m8.1\e[0m\n",
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
      "\e[2K\e[1GYour favourite vitamin? (A-K) E",
      "\e[1A\e[2K\e[1G",
      "Your favourite vitamin? (A-K) \e[32mE\e[0m\n"
    ].join)
  end

  it "provides default error message when wrong input" do
    prompt.input << "A\n2\n"
    prompt.input.rewind

    answer = prompt.ask("How spicy on scale? (1-5)", in: '1-5')

    expect(answer).to eq('2')
    expect(prompt.output.string).to eq([
      "How spicy on scale? (1-5) ",
      "\e[2K\e[1GHow spicy on scale? (1-5) A",
      "\e[2K\e[1GHow spicy on scale? (1-5) A\n",
      "\e[31m>>\e[0m Value A must be within the range 1..5\e[1A",
      "\e[2K\e[1G",
      "How spicy on scale? (1-5) ",
      "\e[2K\e[1GHow spicy on scale? (1-5) 2",
      "\e[2K\e[1GHow spicy on scale? (1-5) 2\n",
      "\e[2K\e[1G",
      "\e[1A\e[2K\e[1G",
      "How spicy on scale? (1-5) \e[32m2\e[0m\n"
    ].join)
  end

  it "overwrites default error message when wrong input" do
    prompt.input << "A\n2\n"
    prompt.input.rewind

    answer = prompt.ask("How spicy on scale? (1-5)") do |q|
      q.in '1-5'
      q.messages[:range?] = 'Ohh dear what is this %{value} doing in %{in}?'
    end

    expect(answer).to eq('2')
    expect(prompt.output.string).to eq([
      "How spicy on scale? (1-5) ",
      "\e[2K\e[1GHow spicy on scale? (1-5) A",
      "\e[2K\e[1GHow spicy on scale? (1-5) A\n",
      "\e[31m>>\e[0m Ohh dear what is this A doing in 1..5?\e[1A",
      "\e[2K\e[1G",
      "How spicy on scale? (1-5) ",
      "\e[2K\e[1GHow spicy on scale? (1-5) 2",
      "\e[2K\e[1GHow spicy on scale? (1-5) 2\n",
      "\e[2K\e[1G",
      "\e[1A\e[2K\e[1G",
      "How spicy on scale? (1-5) \e[32m2\e[0m\n"
    ].join)
  end
end
