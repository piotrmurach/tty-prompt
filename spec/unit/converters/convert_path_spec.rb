# frozen_string_literal: true

RSpec.describe TTY::Prompt::Question, 'convert path' do
  subject(:prompt) { TTY::TestPrompt.new }

  it "converts pathname" do
    path = Pathname.new(::File.join(Dir.pwd, 'spec/unit'))
    prompt.input << "spec/unit"
    prompt.input.rewind

    answer = prompt.ask('File location?', convert: :path)

    expect(answer).to eql(path)
  end
end
