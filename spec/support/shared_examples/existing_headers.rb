shared_examples 'an endpoint with existing Link headers' do
  it 'should keep existing Links' do
    expect(links).to include('<http://example.org/numbers?count=30>; rel="without"')
  end

  it 'should contain pagination Links' do
    expect(links).to include('<http://example.org/numbers?count=30&page=2&with_headers=true>; rel="next"')
    expect(links).to include('<http://example.org/numbers?count=30&page=3&with_headers=true>; rel="last"')
  end

  it 'should give a Total header' do
    expect(total).to eq(30)
  end

  it 'should give a Current-Page header' do
    expect(current_page).to eq(1)
  end

  it 'should give a Total-Pages header' do
    expect(total_pages).to eq(3)
  end
end
