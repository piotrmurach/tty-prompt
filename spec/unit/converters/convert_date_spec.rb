# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, "convert date" do

  subject(:prompt) { TTY::TestPrompt.new}

  it "fails to convert date" do
    prompt.input << "x"
    prompt.input.rewind
    prompt.ask("When were you born?", convert: :date)

    expect(prompt.output.string).to eq([
      "When were you born? ",
      "\e[2K\e[1G",
      "When were you born? x",
      "\e[31m>>\e[0m Cannot convert `x` to 'date' type",
      "\e[1A\e[2K\e[1G",
      "When were you born? ",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "When were you born? \n"
    ].join)
  end

  it "converts date" do
    prompt.input << "20th April 1887"
    prompt.input.rewind
    response = prompt.ask("When were your born?", convert: :date)
    expect(response).to be_kind_of(Date)
    expect(response.day).to eq(20)
    expect(response.month).to eq(4)
    expect(response.year).to eq(1887)
  end

  it "converts datetime" do
    prompt.input << "20th April 1887"
    prompt.input.rewind
    response = prompt.ask("When were your born?", convert: :datetime)
    expect(response).to be_kind_of(DateTime)
    expect(response.day).to eq(20)
    expect(response.month).to eq(4)
    expect(response.year).to eq(1887)
  end
end
