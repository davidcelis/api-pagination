require 'spec_helper'

describe NumbersAPI do
  describe 'GET #index' do
    context 'without enough items to give more than one page' do
      it 'should not paginate' do
        get :numbers, count: 20
        expect(last_response.headers.keys).not_to include('Link')
      end
    end

    context 'with existing Link headers' do
      before { get :numbers, count: 30, with_headers: true }
      let(:links) { last_response.headers['Link'].split(', ') }

      it 'should keep existing Links' do
        expect(links).to include('<http://example.org/numbers?count=30>; rel="without"')
      end

      it 'should contain pagination Links' do
        expect(links).to include('<http://example.org/numbers?count=30&page=2&with_headers=true>; rel="next"')
        expect(links).to include('<http://example.org/numbers?count=30&page=2&with_headers=true>; rel="last"')
      end
    end

    context 'with enough items to paginate' do
      context 'when on the first page' do
        before { get :numbers, :count => 100 }
        let(:links) { last_response.headers['Link'].split(', ') }

        it 'should not give a link with rel "first"' do
          expect(links).not_to include('rel="first"')
        end

        it 'should not give a link with rel "prev"' do
          expect(links).not_to include('rel="prev"')
        end

        it 'should give a link with rel "last"' do
          expect(links).to include('<http://example.org/numbers?count=100&page=4>; rel="last"')
        end

        it 'should give a link with rel "next"' do
          expect(links).to include('<http://example.org/numbers?count=100&page=2>; rel="next"')
        end
      end

      context 'when on the last page' do
        before { get :numbers, :count => 100, :page => 4 }
        let(:links) { last_response.headers['Link'].split(', ') }

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

      context 'when somewhere comfortably in the middle' do
        it 'should give all pagination links' do
          get :numbers, count: 100, page: 2

          links = last_response.headers['Link'].split(', ')

          expect(links).to include('<http://example.org/numbers?count=100&page=1>; rel="first"')
          expect(links).to include('<http://example.org/numbers?count=100&page=4>; rel="last"')
          expect(links).to include('<http://example.org/numbers?count=100&page=3>; rel="next"')
          expect(links).to include('<http://example.org/numbers?count=100&page=1>; rel="prev"')
        end
      end
    end
  end
end
