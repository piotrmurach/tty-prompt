# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'convert file' do
  it "converts to file" do
    file = double(:file)
    prompt = TTY::TestPrompt.new
    prompt.input << "test.txt"
    prompt.input.rewind

    allow(::File).to receive(:open).with(/test\.txt/).and_return(file)
    expect(::File).to receive(:open).with(/test\.txt/)

    answer = prompt.ask("Which file to open?", convert: :file)

    expect(answer).to eq(file)
  end
end
