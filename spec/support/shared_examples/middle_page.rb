shared_examples 'an endpoint with a middle page' do
  it 'should give all pagination links' do
    expect(links).to include('<http://example.org/numbers?count=100&page=1>; rel="first"')
    expect(links).to include('<http://example.org/numbers?count=100&page=4>; rel="last"')
    expect(links).to include('<http://example.org/numbers?count=100&page=3>; rel="next"')
    expect(links).to include('<http://example.org/numbers?count=100&page=1>; rel="prev"')
  end
end
