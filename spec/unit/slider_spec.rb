# encoding: utf-8

RSpec.describe TTY::Prompt, '#slider' do

  subject(:prompt) { TTY::TestPrompt.new }

  it "specifies ranges & step" do
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.slider('What size?', min: 32, max: 54, step: 2)).to eq(44)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "|------",
      "\e[32mO\e[0m",
      "-----|",
      " 44",
      "\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32m44\e[0m\n\e[?25h"
    ].join)
  end

  it "specifies default value" do
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.slider('What size?', min: 32, max: 54, step: 2, default: 38)).to eq(38)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? \e[90m(Use arrow keys, press Enter to select)\e[0m\n",
      "|---",
      "\e[32mO\e[0m",
      "--------|",
      " 38",
      "\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What size? \e[32m38\e[0m\n\e[?25h"
    ].join)
  end
end
