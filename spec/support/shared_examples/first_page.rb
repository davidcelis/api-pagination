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

  it 'should list the first page of numbers in the response body' do
    body = '[1,2,3,4,5,6,7,8,9,10]'
    if defined?(response)
      expect(response.body).to eq(body)
    else
      expect(last_response.body).to eq(body)
    end
  end
end
