# encoding: utf-8

RSpec.describe TTY::Prompt, '#new' do
  it "sets prefix" do
    prompt = described_class.new(prefix: "[?]")
    expect(prompt.prefix).to eq("[?]")
  end

  it "sets input stream" do
    prompt = described_class.new(input: :stream1)
    expect(prompt.input).to eq(:stream1)
  end

  it "sets output stream" do
    prompt = described_class.new(output: :stream2)
    expect(prompt.output).to eq(:stream2)
  end
end
