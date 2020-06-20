# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choices, '#<<' do
  let(:choices) { described_class.new }

  it "adds choice to collection" do
    expect(choices).to be_empty
    choice = TTY::Prompt::Choice.from([:label, 1])
    choices << [:label, 1]
    expect(choices.size).to eq(1)
    expect(choices).to eq([choice])
  end

  it "assigns an index to the added choice" do
    choices << :foo << :bar
    expect(choices.map(&:index)).to eq [0, 1]
  end
end
