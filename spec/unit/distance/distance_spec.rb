# frozen_string_literal: true

RSpec.describe TTY::Prompt::Distance, ".distance" do
  let(:object) { described_class.new }

  subject(:distance) { object.distance(*strings) }

  context "when nil" do
    let(:strings) { [nil, nil] }

    it { is_expected.to eql(0) }
  end

  context "when empty" do
    let(:strings) { ["", ""] }

    it { is_expected.to eql(0) }
  end

  context "with one non empty" do
    let(:strings) { ["abc", ""] }

    it { is_expected.to eql(3) }
  end

  context "when single char" do
    let(:strings) { %w[a abc] }

    it { is_expected.to eql(2) }
  end

  context "when similar" do
    let(:strings) { %w[abc abc] }

    it { is_expected.to eql(0) }
  end

  context "when similar" do
    let(:strings) { %w[abc acb] }

    it { is_expected.to eql(1) }
  end

  context "when end similar" do
    let(:strings) { %w[saturday sunday] }

    it { is_expected.to eql(3) }
  end

  context "when contain similar" do
    let(:strings) { %w[which witch] }

    it { is_expected.to eql(2) }
  end

  context "when prefix" do
    let(:strings) { %w[sta status] }

    it { is_expected.to eql(3) }
  end

  context "when similar" do
    let(:strings) { %w[smellyfish jellyfish] }

    it { is_expected.to eql(2) }
  end

  context "when unicode" do
    let(:strings) { %w[マラソン五輪代表 ララソン五輪代表] }

    it { is_expected.to eql(1) }
  end
end
