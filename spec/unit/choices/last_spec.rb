# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choices, "#last" do
  it "retuens choice last added to collection" do
    choices = described_class.new
    choice_one = TTY::Prompt::Choice.from([:label1, 1])
    choice_two = TTY::Prompt::Choice.from([:label2, 2])

    choices << [:label1, 1]
    expect(choices.size).to eq(1)
    expect(choices.last).to eq(choice_one)

    choices << [:label2, 2]
    expect(choices.size).to eq(2)
    expect(choices.last).to eq(choice_two)
  end
end
