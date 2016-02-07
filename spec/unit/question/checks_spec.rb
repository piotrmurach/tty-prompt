# encoding: utf-8

RSpec.describe TTY::Prompt::Question do

  subject(:prompt) { TTY::TestPrompt.new }

  it "passes range check" do
    question = described_class.new(prompt)
    question.in 1..10

    result = TTY::Prompt::Question::Checks::CheckRange.call(question, 2)

    expect(result).to eq([2])
  end

  it "fails range check" do
    question = described_class.new(prompt)
    question.in 1..10

    result = TTY::Prompt::Question::Checks::CheckRange.call(question, 11)

    expect(result).to eq([11, ["Value 11 must be within the range 1..10"]])
  end

  it "passes validation check" do
    question = described_class.new(prompt)
    question.validate(/\A\d{5}\Z/)

    result = TTY::Prompt::Question::Checks::CheckValidation.call(question, '12345')

    expect(result).to eq(['12345'])
  end

  it "fails validation check" do
    question = described_class.new(prompt)
    question.validate(/\A\d{5}\Z/)

    result = TTY::Prompt::Question::Checks::CheckValidation.call(question, '123')

    expect(result).to eq(['123', ['Your answer is invalid (must match /\\A\\d{5}\\Z/)']])
  end

  it "passes required check" do
    question = described_class.new(prompt)
    question.required true

    result = TTY::Prompt::Question::Checks::CheckRequired.call(question, 'Piotr')

    expect(result).to eq(['Piotr'])
  end

  it "fails required check" do
    question = described_class.new(prompt)
    question.required true

    result = TTY::Prompt::Question::Checks::CheckRequired.call(question, nil)

    expect(result).to eq([nil, ['Value must be provided']])
  end
end
