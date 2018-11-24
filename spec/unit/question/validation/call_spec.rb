# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question::Validation, '#call' do
  let(:pattern) { /^[^\.]+\.[^\.]+/ }

  it "validates nil input" do
    validation = described_class.new(pattern)
    expect(validation.(nil)).to eq(false)
  end

  it "validates successfully when the value matches pattern" do
    validation = described_class.new(pattern)
    expect(validation.('piotr.murach')).to eq(true)
  end

  it "validates with a proc" do
    pat = proc { |input| !pattern.match(input).nil? }
    validation = described_class.new(pat)
    expect(validation.call('piotr.murach')).to eq(true)
  end

  it "validates with custom name" do
    validation = described_class.new(:email)
    expect(validation.call('piotr@example.com')).to eq(true)
  end

  it "fails validation when not maching pattern" do
    validation = described_class.new(pattern)
    expect(validation.('piotrmurach')).to eq(false)
  end
end
