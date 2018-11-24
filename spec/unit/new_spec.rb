# frozen_string_literal: true

RSpec.describe TTY::Prompt, '#new' do
  let(:env)    { { "TTY_TEST" => true } }

  it "sets prefix" do
    prompt = described_class.new(prefix: "[?]", env: env)
    expect(prompt.prefix).to eq("[?]")
  end

  it "sets input stream" do
    prompt = described_class.new(input: :stream1, env: env)
    expect(prompt.input).to eq(:stream1)
  end

  it "sets output stream" do
    prompt = described_class.new(output: :stream2, env: env)
    expect(prompt.output).to eq(:stream2)
  end
end
