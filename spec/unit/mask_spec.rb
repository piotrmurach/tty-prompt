# encoding: utf-8

RSpec.describe TTY::Prompt, '#mask' do

  subject(:prompt) { TTY::TestPrompt.new }

  let(:symbols) { TTY::Prompt::Symbols.symbols }

  it "masks output by default" do
    prompt.input << "pass\r"
    prompt.input.rewind
    answer = prompt.mask("What is your password?")
    expect(answer).to eql("pass")
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[2K\e[1G",
      "What is your password? #{symbols[:dot]}",
      "\e[2K\e[1G",
      "What is your password? #{symbols[:dot] * 2}",
      "\e[2K\e[1G",
      "What is your password? #{symbols[:dot] * 3}",
      "\e[2K\e[1G",
      "What is your password? #{symbols[:dot] * 4}",
      "\e[2K\e[1G",
      "What is your password? \e[32m#{symbols[:dot] * 4}\e[0m\n",
      "\e[1A\e[2K\e[1G",
      "What is your password? \e[32m#{symbols[:dot] * 4}\e[0m\n"
    ].join)
  end

  it 'masks output with custom character' do
    prompt.input << "pass\r"
    prompt.input.rewind
    answer = prompt.mask("What is your password?") { |q| q.mask('*') }
    expect(answer).to eql("pass")
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[2K\e[1G",
      "What is your password? *",
      "\e[2K\e[1G",
      "What is your password? **",
      "\e[2K\e[1G",
      "What is your password? ***",
      "\e[2K\e[1G",
      "What is your password? ****",
      "\e[2K\e[1G",
      "What is your password? \e[32m****\e[0m\n",
      "\e[1A\e[2K\e[1G",
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
      "\e[2K\e[1G",
      "What is your password? ♥",
      "\e[2K\e[1G",
      "What is your password? ♥♥",
      "\e[2K\e[1G",
      "What is your password? ♥♥♥",
      "\e[2K\e[1G",
      "What is your password? \e[32m♥♥♥\e[0m\n",
      "\e[1A\e[2K\e[1G",
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
      "\e[2K\e[1G",
      "What is your password? ",
      "\e[2K\e[1G",
      "What is your password? ",
      "\e[2K\e[1G",
      "What is your password? ",
      "\e[2K\e[1G",
      "What is your password? ",
      "\e[2K\e[1G",
      "What is your password? \n",
      "\e[2K\e[1G",
      "What is your password? \n",
    ].join)
  end

  it "validates input" do
    prompt.input << "no\nyes\n"
    prompt.input.rewind
    answer = prompt.mask('What is your password?') do |q|
      q.echo true
      q.mask '*'
      q.validate(/[a-z]{3,4}/)
      q.messages[:valid?] = 'Not valid'
    end
    expect(answer).to eq('yes')
    expect(prompt.output.string).to eq([
      "What is your password? ",
      "\e[2K\e[1G",
      "What is your password? *",
      "\e[2K\e[1G",
      "What is your password? **",
      "\e[2K\e[1G",
      "What is your password? \e[32m**\e[0m\n",
      "\e[31m>>\e[0m Not valid",
      "\e[1A\e[2K\e[1G",
      "What is your password? \e[31m**\e[0m",
      "\e[2K\e[1G",
      "What is your password? *",
      "\e[2K\e[1G",
      "What is your password? **",
      "\e[2K\e[1G",
      "What is your password? ***",
      "\e[2K\e[1G",
      "What is your password? \e[32m***\e[0m\n",
      "\e[2K\e[1G",
      "\e[1A\e[2K\e[1G",
      "What is your password? \e[32m***\e[0m\n"
    ].join)
  end
end
