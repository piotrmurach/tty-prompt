# frozen_string_literal: true

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
    prompt.input << "aa\n\nbb\n\n\ncc\C-d"
    prompt.input.rewind

    answer = prompt.multiline("Description?")
    expect(answer).to eq(["aa\n", "bb\n", "cc"])
    expect(prompt.output.string).to eq([
      "Description? \e[90m(Press CTRL-D or CTRL-Z to finish)\e[0m\n",
      "\e[2K\e[1Ga",
      "\e[2K\e[1Gaa",
      "\e[2K\e[1Gaa\n",
      "\e[2K\e[1G\n",
      "\e[2K\e[1Gb",
      "\e[2K\e[1Gbb",
      "\e[2K\e[1Gbb\n",
      "\e[2K\e[1G\n",
      "\e[2K\e[1G\n",
      "\e[2K\e[1Gc",
      "\e[2K\e[1Gcc",
      "\e[2K\e[1G\e[1A" * 6,
      "\e[2K\e[1G",
      "Description? \e[32maa ...\e[0m\n"
    ].join)
  end
end
