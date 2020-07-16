# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, "convert to hash" do
  subject(:prompt) { TTY::Prompt::Test.new }

  it "converts answer to a hash" do
    prompt.input << "a:1 b:2 c:3"
    prompt.input.rewind
    answer = prompt.ask("Options?", convert: :map)
    expect(answer).to eq({a: "1", b: "2", c: "3"})
  end

  it "converts answer to a hash of integer values" do
    prompt.input << "a:1 b:2 c:3"
    prompt.input.rewind
    answer = prompt.ask("Options?", convert: :int_map)
    expect(answer).to eq({a: 1, b: 2, c: 3})
  end

  it "converts answer to a hash of boolean values" do
    prompt.input << "a:t b:f c:t"
    prompt.input.rewind
    answer = prompt.ask("Options?", convert: :bool_map)
    expect(answer).to eq({a: true, b: false, c: true})
  end
end
