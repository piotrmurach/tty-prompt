# encoding: utf-8

RSpec.describe TTY::Prompt::Question::Modifier, '#apply_to' do
  let(:instance) { described_class.new modifiers }
  let(:string)   { "Text to be modified"}

  it "doesn't apply modifiers" do
    modifier = described_class.new([])
    expect(modifier.apply_to(string)).to eq(string)
  end

  it 'applies letter case modifications' do
    modifiers = [:down, :capitalize]
    allow(described_class).to receive(:letter_case)
    modifier = described_class.new(modifiers)
    modifier.apply_to(string)
    expect(described_class).to have_received(:letter_case).
      with(modifiers, string)
  end

  it 'applies whitespace modifications' do
    modifiers = [:up, :capitalize]
    allow(described_class).to receive(:whitespace)
    modifier = described_class.new(modifiers)
    modifier.apply_to(string)
    expect(described_class).to have_received(:whitespace).
      with(modifiers, string)
  end
end
