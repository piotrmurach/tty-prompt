# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question::Validation, '#call' do
  let(:pattern) { /^[^\.]+\.[^\.]+/ }
  let(:validation) { described_class.new(pattern) }

  it "validates nil input" do
    expect(validation.(nil)).to eq(false)
  end

  it "validates successfully when the value matches pattern" do
    expect(validation.('piotr.murach')).to eq(true)
  end

  it "fails validation when not maching pattern" do
    expect {
      validation.('piotrmurach')
    }.to raise_error(TTY::Prompt::InvalidArgument)
  end
end
