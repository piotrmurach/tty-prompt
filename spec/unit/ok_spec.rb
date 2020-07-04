# frozen_string_literal: true

RSpec.describe TTY::Prompt, "#ok" do
  subject(:prompt) { TTY::Prompt::Test.new }

  it "prints text in green" do
    prompt.ok("All is fine")
    expect(prompt.output.string).to eq("\e[32mAll is fine\e[0m\n")
  end

  it "prints multiple lines in green" do
    prompt.ok("All is fine", "All is good")
    expect(prompt.output.string).to eq(
      "\e[32mAll is fine\e[0m\n\e[32mAll is good\e[0m\n")
  end

  it "changes color to cyan" do
    prompt.ok("All is fine", color: :cyan)
    expect(prompt.output.string).to eq("\e[36mAll is fine\e[0m\n")
  end
end
