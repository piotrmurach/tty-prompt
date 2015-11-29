# encoding: utf-8

RSpec.describe TTY::Prompt::Choices, '.new' do
  it "creates choices collection" do
    choice_1 = TTY::Prompt::Choice.from(:label1)
    choice_2 = TTY::Prompt::Choice.from(:label2)
    collection = described_class[:label1, :label2]
    expect(collection.choices).to eq([choice_1, choice_2])
  end
end
