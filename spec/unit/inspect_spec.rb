# frozen_string_literal: true

RSpec.describe TTY::Prompt, "#inspect" do
  it "inspects instance attributes" do
    prompt = TTY::TestPrompt.new

    expect(prompt.inspect).to eq([
      "#<TTY::TestPrompt",
      "prefix=\"\"",
      "quiet=false",
      "enabled_color=true",
      "active_color=:green",
      "error_color=:red",
      "help_color=:bright_black",
      "input=#{prompt.input}",
      "output=#{prompt.output}>",
    ].join(" "))
  end
end
