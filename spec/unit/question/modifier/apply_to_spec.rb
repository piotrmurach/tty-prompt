# encoding: utf-8

RSpec.describe TTY::Prompt::Question::Modifier, '#apply_to' do
  let(:string)   { "text   to   be    modified"}

  it "doesn't apply modifiers" do
    modifier = described_class.new([])
    expect(modifier.apply_to(string)).to eq(string)
  end

  it 'combines whitespace & letter case modifications' do
    modifiers = [:collapse, :capitalize]
    modifier = described_class.new(modifiers)
    modified = modifier.apply_to(string)
    expect(modified).to eq('Text to be modified')
  end

  it 'combines letter case & whitespace modifications' do
    modifiers = [:up, :collapse]
    modifier = described_class.new(modifiers)
    modified = modifier.apply_to(string)
    expect(modified).to eq('TEXT TO BE MODIFIED')
  end
end
