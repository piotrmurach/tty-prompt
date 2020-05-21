# frozen_string_literal: true

RSpec.describe TTY::Prompt::ConverterRegistry do
  context "contain" do
    it "doesn't have conversion" do
      registry = described_class.new
      expect(registry.contain?(:unknown)).to eq(false)
    end

    it "contains conversion" do
      registry = described_class.new(foo: ->(val) { val })
      expect(registry.contain?(:foo)).to eq(true)
    end

    it "checks conversion with object type" do
      registry = described_class.new(integer: ->(val) { val })
      expect(registry.contain?(Integer)).to eq(true)
    end
  end

  context "register" do
    it "registers new conversion under single name" do
      registry = described_class.new

      registry.register(:foo) { |val| val }

      expect(registry.contain?(:foo)).to eq(true)
    end

    it "registers new conversion under multiple names" do
      registry = described_class.new

      registry.register(:foo, :fum) { |val| val }

      expect(registry.contain?(:foo)).to eq(true)
      expect(registry.contain?(:fum)).to eq(true)
    end

    it "fails to register conversion" do
      registry = described_class.new(foo: ->(val) { val })

      expect {
        registry.register(:foo) { "value2" }
      }.to raise_error(ArgumentError, "converter for :foo is already registered")
    end
  end

  context "fetch" do
    it "retrieves converter from the registry" do
      conversion = ->(val) { val }
      registry = described_class.new(foo: conversion)

      expect(registry[:foo]).to eq(conversion)
      expect(registry.fetch(:foo)).to eq(conversion)
    end

    it "retrieves uppcase named converter" do
      conversion = ->(val) { val }
      registry = described_class.new(foo: conversion)

      expect(registry["FOO"]).to eq(conversion)
    end

    it "fails to retrieve conversion" do
      registry = described_class.new

      expect {
        registry[:foo]
      }.to raise_error(ArgumentError, "converter :foo is not registered")
    end
  end
end
