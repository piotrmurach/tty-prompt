# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choice, "#<=>" do
  let(:choices) { TTY::Prompt::Choices[:foo, :bar] }

  it "returns negative when the index of the left operand is lower" do
    expect(choices[0] <=> choices[1]).to be_negative
  end

  it "returns positive when the index of the right operand is lower" do
    expect(choices[1] <=> choices[0]).to be_positive
  end

  it "allows to sort instances of Choice in any arbitrary array" do
    arbitrary_array = choices.each.to_a

    expect(arbitrary_array.reverse.sort).to eq(arbitrary_array)
  end
end
