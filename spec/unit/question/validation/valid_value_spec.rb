# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question::Validation, '#valid_value?' do
  let(:validation) { /^[^\.]+\.[^\.]+/ }
  let(:instance) { described_class.new validation }

  it "validates nil input" do
    expect(instance.valid_value?(nil)).to eq(false)
  end

  it "validates successfully when the value matches pattern" do
    expect(instance.valid_value?('piotr.murach')).to eq(true)
  end

  it "fails validation when not maching pattern" do
    expect {
      instance.valid_value?('piotrmurach')
    }.to raise_error(TTY::Prompt::InvalidArgument)
  end
end
