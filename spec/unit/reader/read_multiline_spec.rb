# encoding: utf-8

RSpec.describe TTY::Prompt::Reader, '#read_multiline' do
  let(:input)  { StringIO.new }
  let(:output) { StringIO.new }

  subject(:reader) { described_class.new(input, output) }

  it 'reads no lines' do
    input << ''
    input.rewind
    answer = reader.read_multiline
    expect(answer).to eq([])
  end

  it "reads a line" do
    input << "Single line"
    input.rewind
    answer = reader.read_multiline
    expect(answer).to eq(['Single line'])
  end

  it 'reads few lines' do
    input << "First line\nSecond line\nThird line"
    input.rewind
    answer = reader.read_multiline
    expect(answer).to eq(['First line', 'Second line', 'Third line'])
  end

  it 'reads and yiels every line' do
    input << "First line\nSecond line\nThird line"
    input.rewind
    lines = []
    reader.read_multiline { |line| lines << line }
    expect(lines).to eq(['First line', 'Second line', 'Third line'])
  end

  it 'reads multibyte lines' do
    input << "국경의 긴 터널을 빠져나오자\n설국이었다."
    input.rewind
    lines = []
    reader.read_multiline { |line| lines << line }
    expect(lines).to eq(["국경의 긴 터널을 빠져나오자", '설국이었다.'])
  end
end
