# encoding: utf-8

RSpec.describe TTY::Prompt::Choices, '#<<' do
  it "adds choice to collection" do
    choices = described_class.new
    expect(choices).to be_empty
    choice = TTY::Prompt::Choice.from([:label, 1])
    choices << [:label, 1]
    expect(choices.size).to eq(1)
    expect(choices.to_ary).to eq([choice])
  end
end
