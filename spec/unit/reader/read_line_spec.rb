# encoding: utf-8

RSpec.describe TTY::Prompt::Reader, '#read_line' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }
  let(:env)    { { "TTY_TEST" => true } }

  subject(:reader) { described_class.new(input, output, env: env) }

  it 'masks characters' do
    input << "password\n"
    input.rewind
    answer = reader.read_line(echo: false)
    expect(answer).to eq("password\n")
  end

  it "echoes characters back" do
    input << "password\n"
    input.rewind
    answer = reader.read_line
    expect(answer).to eq("password\n")
    expect(output.string).to eq([
      "\e[2K\e[1Gp",
      "\e[2K\e[1Gpa",
      "\e[2K\e[1Gpas",
      "\e[2K\e[1Gpass",
      "\e[2K\e[1Gpassw",
      "\e[2K\e[1Gpasswo",
      "\e[2K\e[1Gpasswor",
      "\e[2K\e[1Gpassword",
      "\e[2K\e[1Gpassword\n"
    ].join)
  end

  it "doesn't echo characters back" do
    input << "password\n"
    input.rewind
    answer = reader.read_line(echo: false)
    expect(answer).to eq("password\n")
    expect(output.string).to eq('')
  end

  it "displays a prompt before input" do
    input << "aa\n"
    input.rewind
    answer = reader.read_line('>> ')
    expect(answer).to eq("aa\n")
    expect(output.string).to eq([
      "\e[2K\e[1G>> a",
      "\e[2K\e[1G>> aa",
      "\e[2K\e[1G>> aa\n"
    ].join)
  end

  xit 'deletes characters when backspace pressed' do
    input << "aa\ba\bcc\n"
    input.rewind
    answer = reader.read_line
    expect(answer).to eq("acc\n")
  end

  it 'reads multibyte line' do
    input << "한글"
    input.rewind
    answer = reader.read_line
    expect(answer).to eq("한글")
  end
end
