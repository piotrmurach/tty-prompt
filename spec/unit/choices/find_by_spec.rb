# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choices, "#find_by" do
  let(:collection) {
    [
      { name: "large", value: "L", key: "l" },
      { name: "medium", value: "M", key: "m" },
      { name: "small", value: "S", key: "s" }
    ]
  }

  it "finds no matching choice" do
    choices = described_class[*collection]
    expect(choices.find_by(:name, "unknown")).to eq(nil)
  end

  it "finds a matching choice by :name key" do
    choice = TTY::Prompt::Choice.from({ name: "small", value: "S", key: "s" })
    choices = described_class[*collection]
    expect(choices.find_by(:name, "small")).to eq(choice)
  end

  it "finds a matching choice by :value key" do
    choice = TTY::Prompt::Choice.from({ name: "medium", value: "M", key: "m" })
    choices = described_class[*collection]
    expect(choices.find_by(:value, "M")).to eq(choice)
  end

  it "finds a matching choice by :key key" do
    choice = TTY::Prompt::Choice.from({ name: "large", value: "L", key: "l" })
    choices = described_class[*collection]
    expect(choices.find_by(:key, "l")).to eq(choice)
  end
end
