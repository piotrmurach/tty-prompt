# frozen_string_literal: true

RSpec.describe TTY::Prompt, "#slider" do
  subject(:prompt) { TTY::Prompt::Test.new }

  let(:symbols) { TTY::Prompt::Symbols.symbols }
  let(:left_right) { "#{symbols[:arrow_left]}/#{symbols[:arrow_right]}"}

  def output_helper(prompt, choices, active, init: false, hint: false)
    index = choices.index(active)
    out = []
    out << "\e[?25l" if init
    out << prompt << " "
    out << symbols[:line] * index
    out << "\e[32m#{symbols[:bullet]}\e[0m"
    out << symbols[:line] * (choices.size - index - 1)
    out << " " << active
    out << "\n\e[90m(#{hint})\e[0m" if hint
    out << "\e[2K\e[1G"
    out << "\e[1A\e[2K\e[1G" if hint
    out.join
  end

  def exit_message(prompt, choice)
    "#{prompt} \e[32m#{choice}\e[0m\n\e[?25h"
  end

  it "specifies ranges & step" do
    choices = (32..54).step(2).to_a
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.slider("What size?", min: 32, max: 54, step: 2)).to eq(44)
    expect(prompt.output.string).to eq([
      output_helper("What size?", choices, 44, init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      exit_message("What size?", 44)
    ].join)
  end

  it "specifies default value" do
    choices = (32..54).step(2).to_a
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.slider("What size?", min: 32, max: 54, step: 2, default: 38)).to eq(38)
    expect(prompt.output.string).to eq([
      output_helper("What size?", choices, 38, init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      exit_message("What size?", 38)
    ].join)
  end

  it "specifies range through DSL" do
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.slider("What size?") do |range|
              range.help "(Move with arrows)"
              range.default 6
              range.min 0
              range.max 20
              range.step 2
              range.format "|:slider| %d%%"
            end
    expect(value).to eq(6)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? ",
      symbols[:pipe] + symbols[:line] * 3,
      "\e[32m#{symbols[:bullet]}\e[0m",
      "#{symbols[:line] * 7 + symbols[:pipe]} 6%",
      "\n\e[90m(Move with arrows)\e[0m",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "What size? \e[32m6\e[0m\n\e[?25h"
    ].join)
  end

  it "formats via proc" do
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.slider("What size?") do |range|
              range.default 6
              range.max 20
              range.step 2
              range.format ->(slider, value) { "|#{slider}| %d%%" % value }
            end
    expect(value).to eq(6)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? ",
      symbols[:pipe] + symbols[:line] * 3,
      "\e[32m#{symbols[:bullet]}\e[0m",
      "#{symbols[:line] * 7 + symbols[:pipe]} 6%",
      "\n\e[90m(Use #{left_right} arrow keys, press Enter to select)\e[0m",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "What size? \e[32m6\e[0m\n\e[?25h"
    ].join)
  end

  it "changes display colors" do
    prompt.input << "\r"
    prompt.input.rewind
    options = {active_color: :red, help_color: :cyan}
    expect(prompt.slider("What size?", **options)).to eq(5)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? ",
      symbols[:line] * 5,
      "\e[31m#{symbols[:bullet]}\e[0m",
      "#{symbols[:line] * 5} 5",
      "\n\e[36m(Use #{left_right} arrow keys, press Enter to select)\e[0m",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "What size? \e[31m5\e[0m\n\e[?25h"
    ].join)
  end

  it "doesn't allow values outside of range" do
    choices = (0..10).to_a
    prompt.input << "l\r"
    prompt.input.rewind
    prompt.on(:keypress) do |event|
      if event.value = "l"
        prompt.trigger(:keyright)
      end
    end
    res = prompt.slider("What size?", min: 0, max: 10, step: 1, default: 10)
    expect(res).to eq(10)
    expect(prompt.output.string).to eq([
      output_helper("What size?", choices, 10, init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      output_helper("What size?", choices, 10),
      exit_message("What size?", 10)
    ].join)
  end

  it "changes all display symbols" do
    prompt = TTY::Prompt::Test.new(symbols: {
      bullet: "x",
      line: "_"
    })
    prompt.input << "\r"
    prompt.input.rewind

    expect(prompt.slider("What size?", min: 32, max: 54, step: 2)).to eq(44)

    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? ",
      "_" * 6,
      "\e[32mx\e[0m",
      "#{"_" * 5} 44",
      "\n\e[90m(Use #{left_right} arrow keys, press Enter to select)\e[0m",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "What size? \e[32m44\e[0m\n\e[?25h"
    ].join)
  end

  it "changes all display symbols per instance" do
    prompt.input << "\r"
    prompt.input.rewind

    answer = prompt.slider("What size?", min: 32, max: 54, step: 2) do |range|
      range.symbols bullet: "x", line: "_"
    end

    expect(answer).to eq(44)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? ",
      "_" * 6,
      "\e[32mx\e[0m",
      "#{"_" * 5} 44",
      "\n\e[90m(Use #{left_right} arrow keys, press Enter to select)\e[0m",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "What size? \e[32m44\e[0m\n\e[?25h"
    ].join)
  end

  it "sets quiet mode" do
    choices = (32..54).step(2).to_a
    prompt.input << "\r"
    prompt.input.rewind
    expect(prompt.slider("What size?", min: 32, max: 54, step: 2, quiet: true)).to eq(44)
    expect(prompt.output.string).to eq([
      output_helper("What size?", choices, 44, init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      "\e[?25h"
    ].join)
  end

  it "specifies quiet mode through DSL" do
    prompt.input << "\r"
    prompt.input.rewind
    value = prompt.slider("What size?") do |slider|
              slider.quiet true
              slider.default 6
              slider.min 0
              slider.max 20
              slider.step 2
              slider.format "|:slider| %d%%"
            end
    expect(value).to eq(6)
    expect(prompt.output.string).to eq([
      "\e[?25lWhat size? ",
      symbols[:pipe] + symbols[:line] * 3,
      "\e[32m#{symbols[:bullet]}\e[0m",
      "#{symbols[:line] * 7 + symbols[:pipe]} 6%",
      "\n\e[90m(Use #{left_right} arrow keys, press Enter to select)\e[0m",
      "\e[2K\e[1G\e[1A\e[2K\e[1G",
      "\e[?25h"
    ].join)
  end

  it "changes to always show help" do
    choices = (0..10).to_a
    prompt.on(:keypress) do |event|
      prompt.trigger(:keyright) if event.value == "l"
    end
    prompt.input << "l" << "l" << "\r"
    prompt.input.rewind

    res = prompt.slider("What size?", min: 0, max: 10, step: 1,
                        default: 0, show_help: :always)
    expect(res).to eq(2)

    expected_output = [
      output_helper("What size?", choices, 0, init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      output_helper("What size?", choices, 1,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      output_helper("What size?", choices, 2,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      exit_message("What size?", 2),
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "changes to never show help" do
    choices = (0..10).to_a
    prompt.on(:keypress) do |event|
      prompt.trigger(:keyright) if event.value == "l"
    end
    prompt.input << "l" << "l" << "\r"
    prompt.input.rewind

    res = prompt.slider("What size?", min: 0, max: 10, step: 1) do |range|
                          range.default 0
                          range.show_help :never
                        end
    expect(res).to eq(2)

    expected_output = [
      output_helper("What size?", choices, 0, init: true),
      output_helper("What size?", choices, 1),
      output_helper("What size?", choices, 2),
      exit_message("What size?", 2)
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "specifies choices instead of calculated range" do
    choices = %w[a b c d e f g]
    prompt.on(:keypress) do |event|
      prompt.trigger(:keyright) if event.value == "l"
    end
    prompt.input << "l" << "l" << "\r"
    prompt.input.rewind

    res = prompt.slider("What letter?", choices) do |range|
                          range.default "b"
                        end
    expect(res).to eq("d")

    expected_output = [
      output_helper("What letter?", choices, "b", init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      output_helper("What letter?", choices, "c"),
      output_helper("What letter?", choices, "d"),
      exit_message("What letter?", "d")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "specifies choices through DSL" do
    choices = %w[a b c d e f g]
    prompt.on(:keypress) do |event|
      prompt.trigger(:keyleft) if event.value == "l"
    end
    prompt.input << "l" << "l" << "\r"
    prompt.input.rewind

    res = prompt.slider("What letter?") do |range|
                          range.default "c"
                          range.choices choices
                        end
    expect(res).to eq("a")

    expected_output = [
      output_helper("What letter?", choices, "c", init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      output_helper("What letter?", choices, "b"),
      output_helper("What letter?", choices, "a"),
      exit_message("What letter?", "a")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "specifies choices through DSL" do
    choices = %w[a b c d e f g]
    prompt.on(:keypress) do |event|
      prompt.trigger(:keyleft) if event.value == "l"
    end
    prompt.input << "l" << "l" << "\r"
    prompt.input.rewind

    res = prompt.slider("What letter?") do |range|
                          range.default "c"
                          range.choice "a"
                          range.choice "b"
                          range.choice "c"
                          range.choice "d"
                          range.choice "e"
                          range.choice "f"
                          range.choice "g"
                        end
    expect(res).to eq("a")

    expected_output = [
      output_helper("What letter?", choices, "c", init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      output_helper("What letter?", choices, "b"),
      output_helper("What letter?", choices, "a"),
      exit_message("What letter?", "a")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "mixes choices as values and via DSL and keeps ordering" do
    choices = %w[a b c d e f g]
    prompt.on(:keypress) do |event|
      prompt.trigger(:keyleft) if event.value == "l"
    end
    prompt.input << "l" << "l" << "\r"
    prompt.input.rewind

    res = prompt.slider("What letter?", %w[a b c d]) do |range|
                          range.default "c"
                          range.choice "e"
                          range.choice "f"
                          range.choice "g"
                        end
    expect(res).to eq("a")

    expected_output = [
      output_helper("What letter?", choices, "c", init: true,
                    hint: "Use #{left_right} arrow keys, press Enter to select"),
      output_helper("What letter?", choices, "b"),
      output_helper("What letter?", choices, "a"),
      exit_message("What letter?", "a")
    ].join

    expect(prompt.output.string).to eq(expected_output)
  end

  it "sets default choice by name" do
    prompt.input << "\r"
    prompt.input.rewind

    res = prompt.slider("What letter?") do |range|
                          range.default "a"
                          range.choice "a", 1
                          range.choice "b", 2
                          range.choice "c", 3
                        end

    expect(res).to eq(1)
  end

  it "sets default choice by index number" do
    prompt.input << "\r"
    prompt.input.rewind

    res = prompt.slider("What letter?") do |range|
                          range.default 3
                          range.choice "a", 1
                          range.choice "b", 2
                          range.choice "c", 3
                        end

    expect(res).to eq(3)
  end

  it "sets choice value to proc and executes it" do
    prompt.input << "\r"
    prompt.input.rewind

    res = prompt.slider("What letter?") do |range|
                          range.choice "a", 1
                          range.choice "b" do "NOT THE BEEEEEEEES!" end
                          range.choice "c", 3
                        end

    expect(res).to eq("NOT THE BEEEEEEEES!")
  end
end
