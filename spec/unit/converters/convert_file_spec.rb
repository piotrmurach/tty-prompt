# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert file' do
  it "converts to file" do
    file = double(:file)
    prompt = TTY::TestPrompt.new
    prompt.input << "test.txt"
    prompt.input.rewind

    allow(::File).to receive(:dirname).and_return('.')
    allow(::File).to receive(:join).and_return("test.txt")
    allow(::File).to receive(:open).with("test.txt", any_args).and_return(file)

    answer = prompt.ask("Which file to open?", convert: :file)

    expect(answer).to eq(file)
  end
end
