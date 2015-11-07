# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Choice, '#from' do
  it "creates choice from choice" do
    choice = described_class.new(:large, 1)
    expect(described_class.from(choice)).to eq(choice)
  end

  it "creates choice from string" do
    choice = described_class.new('large', 'large')
    expect(described_class.from('large')).to eq(choice)
  end

  it "creates choice from array" do
    choice = described_class.new('large', 1)
    expect(described_class.from([:large, 1])).to eq(choice)
  end

  it "creates choice from hash value" do
    choice = described_class.new('large', 1)
    expect(described_class.from({large: 1})).to eq(choice)
  end
end
