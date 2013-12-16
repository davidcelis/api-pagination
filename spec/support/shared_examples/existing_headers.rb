shared_examples 'an endpoint with existing Link headers' do
  it 'should keep existing Links' do
    expect(links).to include('<http://example.org/numbers?count=30>; rel="without"')
  end

  it 'should contain pagination Links' do
    expect(links).to include('<http://example.org/numbers?count=30&page=2&with_headers=true>; rel="next"')
    expect(links).to include('<http://example.org/numbers?count=30&page=2&with_headers=true>; rel="last"')
  end
end
