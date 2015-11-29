# encoding: utf-8

RSpec.describe TTY::Prompt::Reader, '#getc' do
  let(:prompt) { TTY::TestPrompt.new }
  let(:instance) { described_class.new(prompt) }

  subject(:reader) { instance.getc mask }

  context 'with mask' do
    let(:mask) { '*'}

    it 'masks characters' do
      prompt.input << "password\n"
      prompt.input.rewind
      expect(reader).to eql "password"
      expect(prompt.output.string).to eql("********")
    end
  end

  context "without mask" do
    let(:mask) { }

    it 'masks characters' do
      prompt.input << "password\n"
      prompt.input.rewind
      expect(reader).to eql "password"
      expect(prompt.output.string).to eql("password")
    end

    it 'deletes characters when backspace pressed' do
      prompt.input << "\b\b"
      prompt.input.rewind
      expect(reader).to eql ''
      expect(prompt.output.string).to eql('')
    end
  end
end
