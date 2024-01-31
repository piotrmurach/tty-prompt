# frozen_string_literal: true

RSpec.describe TTY::Prompt::CommandList do
  subject(:prompt) { TTY::Prompt::Test.new }
  before { allow(TTY::Screen).to receive(:width).and_return(200) }

  it "returns nothing when no commands are entered" do
    commands = {
      "read" => ["key"],
      "write" => ["key", "value"]
    }
    prompt.input << "\r"
    prompt.input.rewind

    expected_output = []
    expected_output << ">\n\e[90mread key\nwrite key value\n\e[3A\e[0G\e[1C\e[0m\e[2K\e[1G\e[1B\e[2K\e[1G\e[1B"
    expected_output << "\e[2K\e[1G\e[2A\e[2K\e[1G\e[2K\e[1G\n"
    expect(prompt.command(">", commands)).to eq('')
    expect(prompt.output.string).to eq(expected_output.join)
  end

  it "returns input entered and filters commands" do
    commands = {
      "read" => ["key"],
      "write" => ["key", "value"]
    }

    input = "r"
    prompt.input << "#{input}\r"
    prompt.input.rewind

    expect(prompt.command(">", commands)).to eq(input)
    expected_output = []
    expected_output << ">\n\e[90mread key\nwrite key value\n\e[3A\e[0G\e[1C\e[0m\e[2K\e[1G\e[1B\e[2K\e[1G\e[1B"
    expected_output << "\e[2K\e[1G\e[2A\e[2K\e[1G"
    expected_output << ">r\n\e[90mread key\n\e[2A\e[0G\e[2C\e[0m\e[2K\e[1G\e[1B\e[2K\e[1G\e[1A\e[2K\e[1G\e[2K\e[1Gr\n"
    expect(prompt.output.string).to eq(expected_output.join)
  end

  it "does not output commands when quiet" do
    commands = {
      "read" => ["key"],
      "write" => ["key", "value"]
    }

    input = "r"
    prompt.input << "#{input}\r"
    prompt.input.rewind

    expect(prompt.command(">", commands, quiet: true)).to eq(input)
    expected_output = []
    expected_output << ">\e[2K\e[1G\e[1B\e[2K\e[1G\e[1B\e[2K\e[1G\e[2A\e[2K\e[1G"
    expected_output<< ">r\e[2K\e[1G\e[1B\e[2K\e[1G\e[1A\e[2K\e[1G\e[2K\e[1Gr\n"
    expect(prompt.output.string).to eq(expected_output.join)
  end

  it "limits the number of commands shown" do
    commands = {
      "read" => ["key"],
      "write" => ["key", "value"]
    }

    prompt.input << "\r"
    prompt.input.rewind

    expect(prompt.command(">", commands, { num_commands_shown: 1 })).to eq("")
    expected_output = ">\n\e[90mread key\n\e[2A\e[0G\e[1C\e[0m\e[2K\e[1G\e[1B\e[2K\e[1G\e[1A\e[2K\e[1G\e[2K\e[1G\n"
    expect(prompt.output.string).to eq(expected_output)
  end

  it "removes current input with backspace" do
    commands = {
      "read" => ["key"],
    }

    # Makes a == backspace key press
    prompt.on(:keypress) { |e| prompt.trigger(:keybackspace) if e.value == "a" }
    prompt.input << "ra\r"
    prompt.input.rewind

    expect(prompt.command(">", commands)).to eq("a")
    expected_output = []
    expected_output << ">\n\e[90mread key\n\e[2A\e[0G\e[1C\e[0m\e[2K\e[1G\e[1B\e[2K\e[1G\e[1A\e[2K\e[1G"
    expected_output << ">r\n\e[90mread key\n\e[2A\e[0G\e[2C\e[0m\e[2K\e[1G\e[1B\e[2K\e[1G\e[1A\e[2K\e[1G"
    expected_output << ">a\e[2K\e[1G\e[2K\e[1Ga\n"
    expect(prompt.output.string).to eq(expected_output.join)
  end

  it "allows a block to add commands" do
    prompt.input << "\r"
    prompt.input.rewind

    result = prompt.command(">") do |cmd|
      cmd.command "read", ["key"]
    end

    expect(result).to eq("")
    expected_output = ">\n\e[90mread key\n\e[2A\e[0G\e[1C\e[0m\e[2K\e[1G\e[1B\e[2K\e[1G\e[1A\e[2K\e[1G\e[2K\e[1G\n"
    expect(prompt.output.string).to eq(expected_output)
  end

  it "sets num commands shown from the block" do
    commands = {
      "read" => ["key"],
      "write" => ["key", "value"]
    }

    prompt.input << "\r"
    prompt.input.rewind

    result = prompt.command(">") do |cmd|
      cmd.num_commands_shown(1)
      cmd.commands(commands)
    end

    expect(result).to eq("")
    expected_output = ">\n\e[90mread key\n\e[2A\e[0G\e[1C\e[0m\e[2K\e[1G\e[1B\e[2K\e[1G\e[1A\e[2K\e[1G\e[2K\e[1G\n"
    expect(prompt.output.string).to eq(expected_output)
  end

  it "sets quiet from the block" do
    commands = {
      "read" => ["key"],
      "write" => ["key", "value"]
    }

    prompt.input << "\r"
    prompt.input.rewind

    result = prompt.command(">") do |cmd|
      cmd.quiet(true)
      cmd.commands(commands)
    end

    expect(result).to eq("")
    expected_output = ">\e[2K\e[1G\e[1B\e[2K\e[1G\e[1B\e[2K\e[1G\e[2A\e[2K\e[1G\e[2K\e[1G\n"
    expect(prompt.output.string).to eq(expected_output)
  end
end
