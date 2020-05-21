# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, "convert numbers" do

  subject(:prompt) { TTY::TestPrompt.new }

  it "fails to convert integer" do
    prompt.input << "x"
    prompt.input.rewind
    prompt.ask("What temperature?", convert: :int)

    expect(prompt.output.string).to eq([
      "What temperature? ",
      "\e[2K\e[1G",
      "What temperature? x",
      "\e[31m>>\e[0m Cannot convert `x` to 'int' type",
      "\e[1A\e[2K\e[1G",
      "What temperature? ",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "What temperature? \n"
    ].join)
  end

  it "converts integer" do
    prompt.input << 35
    prompt.input.rewind
    answer = prompt.ask("What temperature?", convert: :int)
    expect(answer).to be_a(Integer)
    expect(answer).to eq(35)
  end

  it "fails to convert float" do
    prompt.input << "x"
    prompt.input.rewind
    prompt.ask("How tall are you?", convert: :float)

    expect(prompt.output.string).to eq([
      "How tall are you? ",
      "\e[2K\e[1G",
      "How tall are you? x",
      "\e[31m>>\e[0m Cannot convert `x` to 'float' type",
      "\e[1A\e[2K\e[1G",
      "How tall are you? ",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "How tall are you? \n"
    ].join)
  end

  it "converts float" do
    number = 6.666
    prompt.input << number
    prompt.input.rewind
    answer = prompt.ask("How tall are you?", convert: :float)
    expect(answer).to be_a(Float)
    expect(answer).to eq(number)
  end
end
