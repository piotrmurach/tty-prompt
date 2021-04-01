# frozen_string_literal: true

RSpec.describe TTY::Prompt::SelectedChoices do
  it "inserts choices by the index order" do
    choices = %w[A B C D E F]
    selected = described_class.new

    expect(selected.to_a).to eq([])
    expect(selected.size).to eq(0)

    selected.insert(5, "F")
    selected.insert(1, "B")
    selected.insert(3, "D")
    selected.insert(0, "A")
    selected.insert(4, "E")
    selected.insert(2, "C")

    expect(selected.to_a).to eq(choices)
    expect(selected.size).to eq(6)

    expect(selected.delete_at(3)).to eq("D")
  end

  it "initializes with selected choices" do
    choices = %w[A B C D E F]
    selected = described_class.new(choices, (0...choices.size).to_a)

    expect(selected.to_a).to eq(choices)
    expect(selected.size).to eq(6)

    choice = selected.delete_at(3)
    expect(choice).to eq("D")

    expect(selected.to_a).to eq(%w[A B C E F])
    expect(selected.size).to eq(5)
  end

  it "inserts and deletes choices" do
    selected = described_class.new

    selected.insert(5, "F")
    selected.insert(1, "B")
    selected.insert(3, "D")
    selected.insert(0, "A")

    expect(selected.to_a).to eq(%w[A B D F])
    expect(selected.size).to eq(4)

    choice = selected.delete_at(3)
    expect(choice).to eq("D")
    expect(selected.to_a).to eq(%w[A B F])
    expect(selected.size).to eq(3)

    selected.insert(4, "E")
    choice = selected.delete_at(-999)

    expect(choice).to eq(nil)
    expect(selected.to_a).to eq(%w[A B E F])
    expect(selected.size).to eq(4)
  end

  it "clears choices" do
    selected = described_class.new(%w[B D F])

    expect(selected.to_a).to eq(%w[B D F])
    expect(selected.size).to eq(3)

    selected.clear

    expect(selected.to_a).to eq([])
    expect(selected.size).to eq(0)
  end
end
