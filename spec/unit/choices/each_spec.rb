# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choices, '.each' do
  it "iterates over collection" do
    choices = described_class[:large, :medium, :small]
    actual = []
    choices.each do |choice|
      actual << choice.name
    end
    expect(actual).to eq([:large, :medium, :small])
    expect(choices.each).to be_kind_of(Enumerator)
  end
end
