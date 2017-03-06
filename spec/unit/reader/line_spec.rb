# encoding: utf-8

RSpec.describe TTY::Prompt::Reader::Line do
  it "inserts characters in line" do
    line = described_class.new('aaaaa')
    line[0] = 'test'
    expect(line.text).to eq('testaaaaa')
    line[4..6] = ''
    expect(line.text).to eq('testaa')
  end

  it "moves cursor left and right" do
    line = described_class.new('aaaaa')
    line.left
    line.left
    line.left
    line.left
    expect(line.cursor).to eq(0)
    expect(line.start?).to eq(true)
    line.left(5)
    expect(line.cursor).to eq(0)
    line.right(20)
    expect(line.cursor).to eq(5)
    expect(line.end?).to eq(true)
  end

  it "inserts char at start of the line" do
    line = described_class.new('aaaaa')
    expect(line.cursor).to eq(4)
    line[0] = 'b'
    expect(line.cursor).to eq(1)
    expect(line.text).to eq('baaaaa')
    line.insert('b')
    expect(line.text).to eq('bbaaaaa')
  end

  it "inserts char at end of the line" do
    line = described_class.new('aaaaa')
    expect(line.cursor).to eq(4)
    line[4] = 'b'
    expect(line.cursor).to eq(5)
    expect(line.text).to eq('aaaaab')
  end

  it "inserts char inside the line" do
    line = described_class.new('aaaaa')
    expect(line.cursor).to eq(4)
    line[2] = 'b'
    expect(line.cursor).to eq(3)
    expect(line.text).to eq('aabaaa')
  end

  it "inserts char outside of the line size" do
    line = described_class.new('aaaaa')
    expect(line.cursor).to eq(4)
    line[10] = 'b'
    expect(line.cursor).to eq(11)
    expect(line.text).to eq('aaaaa     b')
  end

  it "inserts characters with #insert call" do
    line = described_class.new('aaaaa')
    line.left(2)
    expect(line.cursor).to eq(2)
    line.insert(' test ')
    expect(line.text).to eq('aa test aaa')
    expect(line.cursor).to eq(8)
    line.right
    expect(line.cursor).to eq(9)
  end

  it "removes char from current position" do
    line = described_class.new('abcdef')
    line.remove
    line.remove
    expect(line.text).to eq('abcd')
    expect(line.cursor).to eq(3)
    line.left
    line.left
    line.remove
    expect(line.text).to eq('acd')
    expect(line.cursor).to eq(1)
    line.insert('x')
    expect(line.text).to eq('axcd')
  end
end
