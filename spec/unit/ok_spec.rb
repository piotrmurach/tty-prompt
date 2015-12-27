# encoding: utf-8

RSpec.describe TTY::Prompt, 'ok' do
  subject(:prompt) { TTY::TestPrompt.new }

  it 'prints text in green' do
    prompt.ok("All is fine")
    expect(prompt.output.string).to eq("\e[32mAll is fine\e[0m\n")
  end
end
