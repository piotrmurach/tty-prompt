# encoding: utf-8

require 'spec_helper'

RSpec.describe TTY::Prompt::Cursor do
  it "allows to print without mutating state" do
    cursor = described_class.new
    expect(cursor.shell).to eq(false)
    expect(cursor.print.shell).to eq(true)
    expect(cursor.shell).to eq(false)
  end

  it "shows cursor" do
    cursor = described_class.new
    expect(cursor.show).to eq("\e[?25h")
  end

  it "hides cursor" do
    cursor = described_class.new
    expect(cursor.hide).to eq("\e[?25l")
  end

  it "saves cursor position" do
    cursor = described_class.new
    expect(cursor.save).to eq("\e[s")
  end

  it "restores cursor position" do
    cursor = described_class.new
    expect(cursor.restore).to eq("\e[u")
  end

  it "moves up default by 1 line" do
    cursor = described_class.new
    expect(cursor.move_up).to eq("\e[1A")
  end

  it "moves up by 5 lines" do
    cursor = described_class.new
    expect(cursor.move_up(5)).to eq("\e[5A")
  end

  it "moves down default by 1 line" do
    cursor = described_class.new
    expect(cursor.move_down).to eq("\e[1B")
  end

  it "clears line" do
    cursor = described_class.new
    expect(cursor.clear_line).to eq("\e[1000D\e[K")
  end

  it "clears 5 lines up" do
    cursor = described_class.new
    expect(cursor.clear_lines(5)).to eq([
      "\e[1A\e[1000D\e[K",
      "\e[1A\e[1000D\e[K",
      "\e[1A\e[1000D\e[K",
      "\e[1A\e[1000D\e[K",
      "\e[1A\e[1000D\e[K"
    ].join)
  end

  it "clears 5 lines down" do
    cursor = described_class.new
    expect(cursor.clear_lines(5, :down)).to eq([
      "\e[1B\e[1000D\e[K",
      "\e[1B\e[1000D\e[K",
      "\e[1B\e[1000D\e[K",
      "\e[1B\e[1000D\e[K",
      "\e[1B\e[1000D\e[K"
    ].join)
  end
end
