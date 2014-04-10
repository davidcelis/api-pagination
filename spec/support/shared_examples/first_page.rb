shared_examples 'an endpoint with a first page' do
  it 'should not give a link with rel "first"' do
    expect(links).not_to include('rel="first"')
  end

  it 'should not give a link with rel "prev"' do
    expect(links).not_to include('rel="prev"')
  end

  it 'should give a link with rel "last"' do
    expect(links).to include('<http://example.org/numbers?count=100&page=10>; rel="last"')
  end

  it 'should give a link with rel "next"' do
    expect(links).to include('<http://example.org/numbers?count=100&page=2>; rel="next"')
  end

  it 'should give a Total header' do
    expect(total).to eq(100)
  end
end
