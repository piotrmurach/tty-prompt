# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choices, "#enabled" do
  it "returns only choices which aren't disabled" do
    enabled_choice = TTY::Prompt::Choice.new :foo, :bar
    disabled_choice = TTY::Prompt::Choice.new :fizz, :bazz, disabled: true

    choices = described_class[enabled_choice, disabled_choice]
    expect(choices.enabled).to eq [enabled_choice]
  end
end
