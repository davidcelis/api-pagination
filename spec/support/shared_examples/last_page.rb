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
    expect(links).to include('<http://example.org/numbers?count=100&page=9>; rel="prev"')
  end

  it 'should give a Total header' do
    expect(total).to eq(100)
  end

  it 'should list the last page of numbers in the response body' do
    body = '[91,92,93,94,95,96,97,98,99,100]'

    if defined?(response)
      expect(response.body).to eq(body)
    else
      expect(last_response.body).to eq(body)
    end
  end
end
