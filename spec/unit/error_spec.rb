# frozen_string_literal: true

RSpec.describe TTY::Prompt, "#error" do
  subject(:prompt) { TTY::Prompt::Test.new }

  it "displays one message" do
    prompt.error "Nothing is fine!"
    expect(prompt.output.string).to eql "\e[31mNothing is fine!\e[0m\n"
  end

  it "displays many messages" do
    prompt.error "Nothing is fine!", "All is broken!"
    expect(prompt.output.string).to eq(
      "\e[31mNothing is fine!\e[0m\n\e[31mAll is broken!\e[0m\n")
  end

  it "displays message with option" do
    prompt.error "Nothing is fine!", newline: false
    expect(prompt.output.string).to eql "\e[31mNothing is fine!\e[0m"
  end

  it "changes default red color to cyan" do
    prompt.error("All is fine", color: :cyan)
    expect(prompt.output.string).to eq("\e[36mAll is fine\e[0m\n")
  end
end
