# encoding: utf-8

RSpec.describe TTY::Prompt::Question::Modifier, '#whitespace' do
  context "string with whitespaces" do
    let(:string) { "  text\t \n  to\t   modify\r\n" }

    it "trims whitespace" do
      modified = described_class.whitespace(:trim, string)
      expect(modified).to eq("text\t \n  to\t   modify")
    end

    it "chomps whitespace" do
      modified = described_class.whitespace(:chomp, string)
      expect(modified).to eq("  text\t \n  to\t   modify")
    end

    it "collapses text" do
      modified = described_class.whitespace(:collapse, string)
      expect(modified).to eq(" text to modify ")
    end

    it "removes whitespace" do
      modified = described_class.whitespace(:remove, string)
      expect(modified).to eq("texttomodify")
    end
  end

  context "nil (empty user input)" do
    let(:string) { nil }

    example "trim returns nil" do
      modified = described_class.whitespace(:trim, string)
      expect(modified).to be_nil
    end

    example "chomp returns nil" do
      modified = described_class.whitespace(:chomp, string)
      expect(modified).to be_nil
    end

    example "collapse returns nil" do
      modified = described_class.whitespace(:collapse, string)
      expect(modified).to be_nil
    end

    example "remove returns nil" do
      modified = described_class.whitespace(:remove, string)
      expect(modified).to be_nil
    end
  end
end
