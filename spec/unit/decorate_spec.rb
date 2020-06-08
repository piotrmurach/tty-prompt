# frozen_string_literal: true

RSpec.describe TTY::Prompt, "#decorate" do
  it "doesn't decorate empty string" do
    prompt = described_class.new
    expect(prompt.decorate(" \n ")).to eq(" \n ")
  end

  it "doesn't decorate when disabled" do
    prompt = described_class.new(enable_color: false)
    expect(prompt.decorate("string", :green)).to eq("string")
  end

  it "doesn't decorate without additional arguments" do
    prompt = described_class.new
    expect(prompt.decorate("string")).to eq("string")
  end

  it "decorates with a callable object" do
    prompt = described_class.new
    callable = Pastel.new.green.on_red.detach
    expect(prompt.decorate("string", callable)).to eq("\e[32;41mstring\e[0m")
  end

  it "decorates with a proc" do
    prompt = described_class.new
    proc_obj = ->(str) { Pastel.new.green(str) }
    expect(prompt.decorate("string", proc_obj)).to eq("\e[32mstring\e[0m")
  end

  it "decorates string with named colors" do
    prompt = described_class.new
    expect(prompt.decorate("string", :green, :on_red)).to eq("\e[32;41mstring\e[0m")
  end
end
