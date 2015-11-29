# encoding: utf-8

RSpec.describe TTY::Prompt::Question::Modifier, '#whitespace' do
  let(:string) { "  text\t \n  to\t   modify\r\n" }

  subject { described_class.whitespace modifier, string}

  context 'when stripping whitespace' do
    let(:modifier) { :trim }

    it { is_expected.to eq("text\t \n  to\t   modify") }
  end

  context 'when chomping whitespace' do
    let(:modifier) { :chomp }

    it { is_expected.to eq("  text\t \n  to\t   modify") }
  end

  context 'when capitalize' do
    let(:modifier) { :collapse }

    it { is_expected.to eq(" text to modify ") }
  end

  context 'when removing whitespace' do
    let(:modifier) { :remove }

    it { is_expected.to eq("texttomodify") }
  end
end
