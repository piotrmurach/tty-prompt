# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, "convert to array" do
  subject(:prompt) { TTY::Prompt::Test.new }

  it "converts answer to an array" do
    prompt.input << "a,b,c"
    prompt.input.rewind
    answer = prompt.ask("Tags?", convert: :list)
    expect(answer).to eq(%w[a b c])
  end

  it "converts answer to an array of integers" do
    prompt.input << "1,2,3"
    prompt.input.rewind
    answer = prompt.ask("Numbers?", convert: :integers)
    expect(answer).to eq([1, 2, 3])
  end

  it "converts answer to an array of booleans" do
    prompt.input << "t,f,t"
    prompt.input.rewind
    answer = prompt.ask("Numbers?", convert: :bool_list)
    expect(answer).to eq([true, false, true])
  end
end
