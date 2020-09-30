# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choices, "#find_by" do

  let( :collection ) {
    [
      {name: "large", value: "lg", key: "l", key_name: "L"},
      {name: "medium", value: "md", key: "m", key_name: "M"},
      {name: "small", value: "sm", key: "s", key_name: "S"}
    ]
  }

  it "finds a matching choice by key :name" do
    choice = TTY::Prompt::Choice.from(name: "small", value: "sm", key: "s", key_name: "S")
    choices = described_class[*collection]
    expect(choices.find_by(:name, "small")).to eq(choice)
  end

  it "finds a matching choice by key :value" do
    choice = TTY::Prompt::Choice.from(name: "medium", value: "md", key: "m", key_name: "M")
    choices = described_class[*collection]
    expect(choices.find_by(:value, "md")).to eq(choice)
  end

  it "finds a matching choice by key :key" do
    choice = TTY::Prompt::Choice.from(name: "medium", value: "md", key: "m", key_name: "M")
    choices = described_class[*collection]
    expect(choices.find_by(:key, "m")).to eq(choice)
  end

  it "finds a matching choice by key :key_name" do
    choice = TTY::Prompt::Choice.from(name: "large", value: "lg", key: "l", key_name: "L")
    choices = described_class[*collection]
    expect(choices.find_by(:key_name, "L")).to eq(choice)
  end
end
