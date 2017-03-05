# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#multiline' do
  it 'reads no lines' do
    prompt = TTY::TestPrompt.new
    prompt.input << "\C-d"
    prompt.input.rewind

    answer = prompt.multiline("Description?")

    expect(answer).to eq([])
    expect(prompt.output.string).to eq([
      "Description? \e[90m(Press CTRL-D or CTRL-Z to finish)\e[0m\n",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "Description? \n"
    ].join)
  end

  it "uses defualt when no input" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\C-d"
    prompt.input.rewind

    answer = prompt.multiline("Description?", default: 'A super sweet prompt')

    expect(answer).to eq([])
    expect(prompt.output.string).to eq([
      "Description? \e[90m(Press CTRL-D or CTRL-Z to finish)\e[0m\n",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "Description? \e[32mA super sweet prompt\e[0m\n"
    ].join)
  end

  it "changes help text" do
    prompt = TTY::TestPrompt.new
    prompt.input << "\C-d"
    prompt.input.rewind

    answer = prompt.multiline("Description?") do |q|
      q.default 'A super sweet prompt'
      q.help '(Press thy ctrl-d to end)'
    end

    expect(answer).to eq([])
    expect(prompt.output.string).to eq([
      "Description? \e[90m(Press thy ctrl-d to end)\e[0m\n",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "Description? \e[32mA super sweet prompt\e[0m\n"
    ].join)
  end

  it 'reads multiple lines with empty lines' do
    prompt = TTY::TestPrompt.new
    prompt.input << "First line\n\nSecond line\n\n\nThird line\C-d"
    prompt.input.rewind

    answer = prompt.multiline("Description?")

    expect(answer).to eq(["First line\n", "Second line\n", "Third line"])
    expect(prompt.output.string).to eq([
      "Description? \e[90m(Press CTRL-D or CTRL-Z to finish)\e[0m\n",
      "First line\n\n",
      "Second line\n\n\n",
      "Third line",
      "\e[2K\e[1G\e[1A" * 6,
      "\e[2K\e[1G",
      "Description? \e[32mFirst line ...\e[0m\n"
    ].join)
  end
end
