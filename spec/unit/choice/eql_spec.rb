# frozen_string_literal: true

RSpec.describe TTY::Prompt::Choice, "#==" do
  it "is true with the same name and value attributes" do
    expect(described_class.new(:large, 1)).
      to eq(described_class.new(:large, 1))
  end

  it "is false with different name attribute" do
    expect(described_class.new(:large, 1)).
      not_to eq(described_class.new(:medium, 1))
  end

  it "is false with different value attribute" do
    expect(described_class.new(:large, 1)).
      not_to eq(described_class.new(:large, 2))
  end

  it "is false with different key attribute" do
    expect(described_class.new(:large, 1, key: "h")).
      not_to eq(described_class.new(:large, 1, key: "g"))
  end

  it "is false with different key_name attribute" do
    expect(described_class.new(:large, 1, key: "h", key_name: "aych")).
      not_to eq(described_class.new(:large, 1, key: "h", key_name: "gee"))
  end

  it "is false with non-choice object" do
    expect(described_class.new(:large, 1)).not_to eq(:other)
  end
end
