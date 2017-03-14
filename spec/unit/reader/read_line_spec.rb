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
    expect(output.string).to eq("")
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
