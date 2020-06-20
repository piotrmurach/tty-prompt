# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choices, '.new' do
  let(:choice_1) { TTY::Prompt::Choice.from(:label1) }
  let(:choice_2) { TTY::Prompt::Choice.from(:label2) }

  subject { described_class[:label1, :label2] }

  it "creates choices collection with proper indices" do
    expect(subject).to eq([choice_1, choice_2])
  end

  it "assignes proper indices to instances of Choice" do
    expect(subject.map(&:index)).to eq [0, 1]
  end
end
