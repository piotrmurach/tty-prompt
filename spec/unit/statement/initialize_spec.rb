# encoding: utf-8

RSpec.describe TTY::Prompt::Statement, '#new' do
  it "forces newline after the prompt message" do
    prompt = TTY::TestPrompt.new
    statement = described_class.new(prompt)
    expect(statement.newline).to eq(true)
  end

  it "displays prompt message in color" do
    prompt = TTY::TestPrompt.new
    statement = described_class.new(prompt)
    expect(statement.color).to eq(false)
  end
end
