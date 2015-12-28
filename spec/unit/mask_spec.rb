# encoding: utf-8

RSpec.describe TTY::Prompt, '#mask' do

  subject(:prompt) { TTY::TestPrompt.new }

  it "masks output by default" do
    prompt.input << "pass\r"
    prompt.input.rewind
    answer = prompt.mask("What is your password?")
    expect(answer).to eql("pass")
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[1000D\e[K",
      "What is your password? •",
      "\e[1000D\e[K",
      "What is your password? ••",
      "\e[1000D\e[K",
      "What is your password? •••",
      "\e[1000D\e[K",
      "What is your password? ••••",
      "\e[1000D\e[K",
      "What is your password? \e[32m••••\e[0m\n",
      "\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What is your password? \e[32m••••\e[0m\n"
    ].join)
  end

  it 'masks output with custom character' do
    prompt.input << "pass\r"
    prompt.input.rewind
    answer = prompt.mask("What is your password?") { |q| q.mask('*') }
    expect(answer).to eql("pass")
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[1000D\e[K",
      "What is your password? *",
      "\e[1000D\e[K",
      "What is your password? **",
      "\e[1000D\e[K",
      "What is your password? ***",
      "\e[1000D\e[K",
      "What is your password? ****",
      "\e[1000D\e[K",
      "What is your password? \e[32m****\e[0m\n",
      "\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What is your password? \e[32m****\e[0m\n",
    ].join)
  end

  it "masks with unicode character" do
    prompt.input << "lov\n"
    prompt.input.rewind
    answer = prompt.mask("What is your password?", mask: "\u2665")
    expect(answer).to eql("lov")
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[1000D\e[K",
      "What is your password? ♥",
      "\e[1000D\e[K",
      "What is your password? ♥♥",
      "\e[1000D\e[K",
      "What is your password? ♥♥♥",
      "\e[1000D\e[K",
      "What is your password? \e[32m♥♥♥\e[0m\n",
      "\e[1000D\e[K\e[1A\e[1000D\e[K",
      "What is your password? \e[32m♥♥♥\e[0m\n",
    ].join)
  end

  it 'ignores mask if echo is off' do
    prompt.input << "pass\n"
    prompt.input.rewind
    answer = prompt.mask('What is your password?') do |q|
      q.echo false
      q.mask '*'
    end
    expect(answer).to eql("pass")
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[1000D\e[K",
      "What is your password? ",
      "\e[1000D\e[K",
      "What is your password? ",
      "\e[1000D\e[K",
      "What is your password? ",
      "\e[1000D\e[K",
      "What is your password? ",
      "\e[1000D\e[K",
      "What is your password? \n",
      "\e[1000D\e[K",
      "What is your password? \n",
    ].join)
  end
end
