# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Question::Validation, '#coerce' do
  let(:instance) { described_class.new }

  it "coerces into proc" do
    validation = lambda { "^[^\.]+\.[^\.]+" }
    expect(instance.coerce(validation)).to be_kind_of(Proc)
  end

  it "cources into regex" do
    validation = "^[^\.]+\.[^\.]+"
    expect(instance.coerce(validation)).to be_kind_of(Regexp)
  end

  it "fails to coerce validation" do
    validation = Object.new
    expect {
      instance.coerce(validation)
    }.to raise_error(TTY::Prompt::ValidationCoercion)
  end
end
