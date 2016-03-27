# encoding: utf-8

RSpec.describe TTY::Prompt::Choice, '#from' do
  it "skips Choice instance" do
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

  it "create choice from hash with key property" do
    default = {key: 'h', name: 'Help', value: :help}
    choice = described_class.new('Help', :help)
    expect(described_class.from(default)).to eq(choice)
  end
end
