# frozen_string_literal: true

RSpec.describe TTY::Utils do
  context "#blank?" do
    {
      nil => true,
      "" => true,
      "\n\t\s" => true,
      "    " => true,
      "foo" => false,
      :foo => false
    }.each do |value, result|
      it "detects blank of #{value.inspect} as #{result}" do
        expect(described_class.blank?(value)).to eq(result)
      end
    end
  end

  context "#deep_copy" do
    [
      "",
      ["foo", {bar: "baz"}, :fum, 11]
    ].each do |obj|
      it "copies #{obj.inspect}" do
        copy = described_class.deep_copy(obj)
        expect(obj).to eq(copy)
        expect(obj).not_to equal(copy)
      end
    end
  end
end
