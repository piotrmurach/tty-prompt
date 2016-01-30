# encoding

RSpec.describe TTY::Prompt::Reader::KeyEvent, '::from' do

  it "parses ctrl+h" do
    event = described_class.from("\b")
    expect(event.key.name).to eq(:backspace)
    expect(event.value).to eq("\b")
  end

  it "parses lowercase char" do
    event = described_class.from('a')
    expect(event.key.name).to eq('a')
    expect(event.value).to eq('a')
  end

  it "parses uppercase char" do
    event = described_class.from('A')
    expect(event.key.name).to eq('a')
    expect(event.value).to eq('A')
  end

  it "parses f5 key" do
    event = described_class.from("\e[15~")
    expect(event.key.name).to eq(:f5)
  end

  it "parses up key" do
    event = described_class.from("\e[A")
    expect(event.key.name).to eq(:up)
  end

  it "parses up key on gnome" do
    event = described_class.from("\eOA")
    expect(event.key.name).to eq(:up)
  end

  it "parses down key" do
    event = described_class.from("\e[B")
    expect(event.key.name).to eq(:down)
  end

  it "parses right key" do
    event = described_class.from("\e[C")
    expect(event.key.name).to eq(:right)
  end

  it "parses left key" do
    event = described_class.from("\e[D")
    expect(event.key.name).to eq(:left)
  end

  it "parses clear key" do
    event = described_class.from("\e[E")
    expect(event.key.name).to eq(:clear)
  end

  it "parses end key" do
    event = described_class.from("\e[F")
    expect(event.key.name).to eq(:end)
  end

  it "parses home key" do
    event = described_class.from("\e[H")
    expect(event.key.name).to eq(:home)
  end
end
