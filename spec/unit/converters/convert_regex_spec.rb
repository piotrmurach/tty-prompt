# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, 'convert regexp' do
  it "converts regex" do
    prompt = TTY::TestPrompt.new
    prompt.input << "[a-z]*"
    prompt.input.rewind
    answer = prompt.ask("Regex?", convert: :regexp)
    expect(answer).to be_a(Regexp)
    expect(answer).to eq(/[a-z]*/)
  end
end
