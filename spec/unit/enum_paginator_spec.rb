# encoding: utf-8

RSpec.describe TTY::Prompt::EnumPaginator, '#paginate' do
  it "ignores per_page when equal items " do
    list = %w(a b c d)
    paginator = described_class.new({per_page: 4})

    expect(paginator.paginate(list, 1).to_a).to eq([
      ['a',0],['b',1],['c',2],['d',3]])
  end

  it "ignores per_page when less items " do
    list = %w(a b c d)
    paginator = described_class.new({per_page: 5})

    expect(paginator.paginate(list, 1).to_a).to eq([
      ['a',0],['b',1],['c',2],['d',3]])
  end

  it "paginates items matching per_page count" do
    list = %w(a b c d e f)
    paginator = described_class.new({per_page: 3})

    expect(paginator.paginate(list, 1).to_a).to eq([['a',0], ['b',1], ['c',2]])
    expect(paginator.paginate(list, 2).to_a).to eq([['a',0], ['b',1], ['c',2]])
    expect(paginator.paginate(list, 3).to_a).to eq([['a',0], ['b',1], ['c',2]])
    expect(paginator.paginate(list, 4).to_a).to eq([['d',3], ['e',4], ['f',5]])
    expect(paginator.paginate(list, 5).to_a).to eq([['d',3], ['e',4], ['f',5]])
    expect(paginator.paginate(list, 6).to_a).to eq([['d',3], ['e',4], ['f',5]])
    expect(paginator.paginate(list, 7).to_a).to eq([['d',3], ['e',4], ['f',5]])
  end

  it "paginates items not matching per_page count" do
    list = %w(a b c d e f g)
    paginator = described_class.new({per_page: 3})

    expect(paginator.paginate(list, 1).to_a).to eq([['a',0], ['b',1], ['c',2]])
    expect(paginator.paginate(list, 2).to_a).to eq([['a',0], ['b',1], ['c',2]])
    expect(paginator.paginate(list, 3).to_a).to eq([['a',0], ['b',1], ['c',2]])
    expect(paginator.paginate(list, 4).to_a).to eq([['d',3], ['e',4], ['f',5]])
    expect(paginator.paginate(list, 5).to_a).to eq([['d',3], ['e',4], ['f',5]])
    expect(paginator.paginate(list, 6).to_a).to eq([['d',3], ['e',4], ['f',5]])
    expect(paginator.paginate(list, 7).to_a).to eq([['g',6]])
    expect(paginator.paginate(list, 8).to_a).to eq([['g',6]])
  end

  it "finds maximum index for current selection" do
    list = %w(a b c d e f g)
    paginator = described_class.new({per_page: 3, default: 0})

    paginator.paginate(list, 4)
    expect(paginator.max_index).to eq(5)
    paginator.paginate(list, 5)
    expect(paginator.max_index).to eq(5)
    paginator.paginate(list, 7)
    expect(paginator.max_index).to eq(8)
  end

  it "starts with default selection" do
    list = %w(a b c d e f g)
    paginator = described_class.new({per_page: 3, default: 3})

    expect(paginator.paginate(list, 4).to_a).to eq([['d',3], ['e',4], ['f',5]])
  end
end
