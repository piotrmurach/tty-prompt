# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, "convert range" do
  subject(:prompt) { TTY::Prompt::Test.new }

  it "converts with valid range" do
    prompt.input << "20-30"
    prompt.input.rewind
    answer = prompt.ask("Which age group?", convert: :range)
    expect(answer).to be_a(Range)
    expect(answer).to eq(20..30)
  end

  it "fails to convert to range" do
    prompt.input << "x"
    prompt.input.rewind
    prompt.ask("Which age group?", convert: :range)

    expect(prompt.output.string).to eq([
      "Which age group? ",
      "\e[2K\e[1G",
      "Which age group? x",
      "\e[31m>>\e[0m Cannot convert `x` to 'range' type",
      "\e[1A\e[2K\e[1G",
      "Which age group? ",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "Which age group? \n"
    ].join)
  end
end
