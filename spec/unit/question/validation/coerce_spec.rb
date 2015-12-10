# encoding: utf-8

RSpec.describe TTY::Prompt::Question::Validation, '#coerce' do
  let(:instance) { described_class.new }

  it "coerces lambda into proc" do
    pattern = lambda { "^[^\.]+\.[^\.]+" }
    validation = described_class.new(pattern)
    expect(validation.pattern).to be_a(Proc)
  end

  it "doesn't coerce symbols" do
    pattern = :email
    validation =described_class.new(pattern)
    expect(validation.pattern).to eq(:email)
  end

  it "coerces into regex" do
    pattern = /^[^\.]+\.[^\.]+/
    validation = described_class.new(pattern)
    expect(validation.pattern).to be_a(Regexp)
  end

  it "fails to coerce pattern into validation" do
    pattern = Object.new
    expect {
      described_class.new(pattern)
    }.to raise_error(TTY::Prompt::ValidationCoercion)
  end
end
