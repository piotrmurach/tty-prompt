# encoding: utf-8

RSpec.describe TTY::Prompt::Question::Modifier, '#whitespace' do
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
