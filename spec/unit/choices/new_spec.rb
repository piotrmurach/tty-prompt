# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choices, ".new" do
  it "creates choices collection" do
    choice1 = TTY::Prompt::Choice.from(:label1)
    choice2 = TTY::Prompt::Choice.from(:label2)
    collection = described_class[:label1, :label2]
    expect(collection).to eq([choice1, choice2])
  end
end
