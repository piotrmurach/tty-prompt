# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question do

  subject(:prompt) { TTY::Prompt::Test.new }

  it "passes range check" do
    question = described_class.new(prompt)
    question.in 1..10

    result = TTY::Prompt::Question::Checks::CheckRange.call(question, 2)

    expect(result).to eq([2])
  end

  it "fails range check" do
    question = described_class.new(prompt, messages: TTY::Prompt.messages)
    question.in 1..10

    result = TTY::Prompt::Question::Checks::CheckRange.call(question, 11)

    expect(result).to eq([11, ["Value 11 must be within the range 1..10"]])
  end

  it "fails range check" do
    question = described_class.new(prompt)
    question.in 1..10, "Outside of range!"

    result = TTY::Prompt::Question::Checks::CheckRange.call(question, 11)

    expect(result).to eq([11, ["Outside of range!"]])
  end

  it "passes validation check" do
    question = described_class.new(prompt)
    question.validate(/\A\d{5}\Z/)

    result = TTY::Prompt::Question::Checks::CheckValidation.call(question, "12345")

    expect(result).to eq(["12345"])
  end

  it "fails validation check" do
    question = described_class.new(prompt, messages: TTY::Prompt.messages)
    question.validate(/\A\d{5}\Z/)

    result = TTY::Prompt::Question::Checks::CheckValidation.call(question, "123")

    expect(result).to eq(["123", ["Your answer is invalid (must match /\\A\\d{5}\\Z/)"]])
  end

  it "fails validation check with inlined custom message" do
    question = described_class.new(prompt)
    question.validate(/\A\w+@\w+\.\w+\Z/, "Invalid email address: %{value}")

    result = TTY::Prompt::Question::Checks::CheckValidation.call(question,
                                                                 "piotr@com")

    expect(result).to eq(["piotr@com", ["Invalid email address: piotr@com"]])
  end

  it "fails validation check with custom message" do
    question = described_class.new(prompt)
    question.validate(/\A\w+@\w+\.\w+\Z/)
    question.messages[:valid?] = "Invalid email address: %{value}"

    result = TTY::Prompt::Question::Checks::CheckValidation.call(question,
                                                                 "piotr@com")

    expect(result).to eq(["piotr@com", ["Invalid email address: piotr@com"]])
  end

  it "passes required check" do
    question = described_class.new(prompt)
    question.required true

    result = TTY::Prompt::Question::Checks::CheckRequired.call(question, "Piotr")

    expect(result).to eq(["Piotr"])
  end

  it "fails required check" do
    question = described_class.new(prompt, messages: TTY::Prompt.messages)
    question.required true

    result = TTY::Prompt::Question::Checks::CheckRequired.call(question, nil)

    expect(result).to eq([nil, ["Value must be provided"]])
  end

  it "fails required check with custom message" do
    question = described_class.new(prompt)
    question.required true, "Required input"

    result = TTY::Prompt::Question::Checks::CheckRequired.call(question, nil)

    expect(result).to eq([nil, ["Required input"]])
  end

  it "passes convert check" do
    question = described_class.new(prompt)
    question.convert :bool

    result = TTY::Prompt::Question::Checks::CheckConversion.call(question, "t")

    expect(result).to eq([true])
  end

  it "fails convert check" do
    question = described_class.new(prompt, messages: TTY::Prompt.messages)
    question.convert :bool

    result = TTY::Prompt::Question::Checks::CheckConversion.call(question, "x")

    expect(result).to eq(["x", ["Cannot convert `x` to 'bool' type"]])
  end

  it "fails convert check with custom message" do
    question = described_class.new(prompt)
    question.convert :bool, "Wrong conversion value of `%{value}` for %{type}"

    result = TTY::Prompt::Question::Checks::CheckConversion.call(question, "x")

    expect(result).to eq(["x", ["Wrong conversion value of `x` for bool"]])
  end
end
