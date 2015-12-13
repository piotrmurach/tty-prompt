# encoding: utf-8

RSpec.describe TTY::Prompt::Question, 'read_file' do
  it "converts to file" do
    prompt = TTY::TestPrompt.new
    file = spy(:file)
    allow(File).to receive(:open).with(/test\.txt/).and_return(file)
    prompt.input << "test.txt"
    prompt.input.rewind
    answer = prompt.ask("Which file to open?", read: :file)
    expect(answer).to eq(file)
    expect(File).to have_received(:open).with(/test\.txt/)
  end
end
