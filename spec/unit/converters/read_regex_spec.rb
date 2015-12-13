# encoding: utf-8

RSpec.describe TTY::Prompt::Question do
  it "reads regex" do
    prompt = TTY::TestPrompt.new
    prompt.input << "[a-z]*"
    prompt.input.rewind
    answer = prompt.ask("Regex?", read: :regexp)
    expect(answer).to be_a(Regexp)
    expect(answer).to eq(/[a-z]*/)
  end
end
