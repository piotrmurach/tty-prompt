# encoding: utf-8

RSpec.describe TTY::Prompt::Question, '#keypress' do
  it 'receives line feed with echo on' do
    prompt = TTY::TestPrompt.new
    prompt.input << "\n"
    prompt.input.rewind

    answer = prompt.keypress("Press key:", echo: true)

    expect(answer).to eq("\n")
    expect(prompt.output.string).to eq([
      "Press key: ",
      "\e[2K\e[1G",
      "Press key: \e[32m\n\e[0m\n",
    ].join)
  end

  it 'asks for a keypress with echo on' do
    prompt = TTY::TestPrompt.new
    prompt.input << "abcd"
    prompt.input.rewind

    answer = prompt.keypress("Press key:", echo: true)

    expect(answer).to eq("a")
    expect(prompt.output.string).to eq([
      "Press key: ",
      "\e[2K\e[1G",
      "Press key: \e[32ma\e[0m\n",
    ].join)
  end

  it 'asks for a keypress with echo off' do
    prompt = TTY::TestPrompt.new
    prompt.input << "abcd"
    prompt.input.rewind

    answer = prompt.keypress("Press key:")

    expect(answer).to eq("a")
    expect(prompt.output.string).to eq([
      "Press key: ",
      "\e[2K\e[1G",
      "Press key: \n",
    ].join)
  end

  it "interrupts input" do
    prompt = TTY::TestPrompt.new(interrupt: :exit)
    prompt.input << "\x03"
    prompt.input.rewind

    expect {
      prompt.keypress("Press key:")
    }.to raise_error(SystemExit)
  end
end
