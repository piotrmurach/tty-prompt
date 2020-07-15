# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, "convert to array" do
  subject(:prompt) { TTY::Prompt::Test.new }

  it "converts answer to an array" do
    prompt.input << "a,b,c"
    prompt.input.rewind
    answer = prompt.ask("Tags?", convert: :list)
    expect(answer).to eq(%w[a b c])
  end
end
