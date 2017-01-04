# encoding: utf-8

RSpec.describe TTY::Prompt::Question::Modifier, '#letter_case' do
  context "string" do
    let(:string) { 'text to modify' }

    it "changes to uppercase" do
      modified = described_class.letter_case(:up, string)
      expect(modified).to eq('TEXT TO MODIFY')
    end

    it "changes to lower case" do
      modified = described_class.letter_case(:down, string)
      expect(modified).to eq('text to modify')
    end

    it "capitalizes text" do
      modified = described_class.letter_case(:capitalize, string)
      expect(modified).to eq('Text to modify')
    end
  end

  context "nil (empty user input)" do
    let(:string) { nil }

    example "up returns nil" do
      modified = described_class.letter_case(:up, string)
      expect(modified).to be_nil
    end

    example "down returns nil" do
      modified = described_class.letter_case(:down, string)
      expect(modified).to be_nil
    end

    example "capitalize returns nil" do
      modified = described_class.letter_case(:capitalize, string)
      expect(modified).to be_nil
    end
  end
end
