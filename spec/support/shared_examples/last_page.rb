shared_examples 'an endpoint with a last page' do
  it 'should not give a link with rel "last"' do
    expect(links).not_to include('rel="last"')
  end

  it 'should not give a link with rel "next"' do
    expect(links).not_to include('rel="next"')
  end

  it 'should give a link with rel "first"' do
    expect(links).to include('<http://example.org/numbers?count=100&page=1>; rel="first"')
  end

  it 'should give a link with rel "prev"' do
    expect(links).to include('<http://example.org/numbers?count=100&page=3>; rel="prev"')
  end
end
