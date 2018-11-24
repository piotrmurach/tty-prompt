# frozen_string_literal: true

RSpec.describe TTY::Prompt, '#subscribe' do
  it "subscribes to key events only for the current prompt" do
    prompt = TTY::TestPrompt.new
    uuid = '14c3b412-e0c5-4ff5-9cd8-25ec3f18c702'
    prompt.input << "3\n#{uuid}\n"
    prompt.input.rewind
    keys = []

    prompt.on(:keypress) do |event|
      keys << :enter if event.key.name == :enter
    end

    letter = prompt.enum_select('Select something', ('A'..'Z').to_a)
    id = prompt.ask('Request ID?')

    expect(letter).to eq('C')
    expect(id).to eq(uuid)
    expect(keys).to eq([:enter, :enter])
  end
end
