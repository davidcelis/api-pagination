require 'spec_helper'
require 'support/shared_examples/existing_headers'
require 'support/shared_examples/first_page'
require 'support/shared_examples/middle_page'
require 'support/shared_examples/last_page'

describe NumbersAPI do
  it { is_expected.to be_kind_of(Grape::Pagination) }

  describe 'GET #index' do
    let(:link) { last_response.headers['Link'] }
    let(:links) { link.split(', ') }
    let(:total) { last_response.headers['Total'].to_i }
    let(:per_page) { last_response.headers['Per-Page'].to_i }

    context 'without enough items to give more than one page' do
      before { get '/numbers', :count => 10 }

      it 'should not paginate' do
        expect(last_response.headers.keys).not_to include('Link')
      end

      it 'should give a Total header' do
        expect(total).to eq(10)
      end

      it 'should give a Per-Page header' do
        expect(per_page).to eq(10)
      end

      it 'should list all numbers in the response body' do
        body = '[1,2,3,4,5,6,7,8,9,10]'
        expect(last_response.body).to eq(body)
      end
    end

    context 'with existing Link headers' do
      before { get '/numbers', :count => 30, :with_headers => true }

      it_behaves_like 'an endpoint with existing Link headers'
    end

    context 'with enough items to paginate' do
      context 'when on the first page' do
        before { get '/numbers', :count => 100 }

        it_behaves_like 'an endpoint with a first page'
      end

      context 'when on the last page' do
        before { get '/numbers', :count => 100, :page => 10 }

        it_behaves_like 'an endpoint with a last page'
      end

      context 'when somewhere comfortably in the middle' do
        before { get '/numbers', :count => 100, :page => 2 }

        it_behaves_like 'an endpoint with a middle page'
      end

      context 'without a max_per_page setting' do
        before { get '/numbers', :count => 100, :per_page => 30 }

        it 'should list all numbers within per page in the response body' do
          body = '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30]'

          expect(last_response.body).to eq(body)
        end
      end

      context 'with a max_per_page setting not enforced' do
        before { get '/numbers_with_max_per_page', :count => 100, :per_page => 30 }

        it 'should not go above the max_per_page_limit' do
          body = '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]'

          expect(last_response.body).to eq(body)
        end
      end

      context 'with a max_per_page setting enforced' do
        before { get '/numbers_with_enforced_max_per_page', :count => 100, :per_page => 30 }

        it 'should not allow value above the max_per_page_limit' do
          body = '{"error":"per_page does not have a valid value"}'

          expect(last_response.body).to eq(body)
        end
      end
    end

    context 'with custom response headers' do
      before do
        ApiPagination.config.total_header    = 'X-Total-Count'
        ApiPagination.config.per_page_header = 'X-Per-Page'
        ApiPagination.config.page_header     = 'X-Page'

        get '/numbers', count: 10
      end

      after do
        ApiPagination.config.total_header    = 'Total'
        ApiPagination.config.per_page_header = 'Per-Page'
        ApiPagination.config.page_header     = nil
      end

      let(:total) { last_response.header['X-Total-Count'].to_i }
      let(:per_page) { last_response.header['X-Per-Page'].to_i }
      let(:page) { last_response.header['X-Page'].to_i }

      it 'should give a X-Total-Count header' do
        headers_keys = last_response.headers.keys

        expect(headers_keys).not_to include('Total')
        expect(headers_keys).to include('X-Total-Count')
        expect(total).to eq(10)
      end

      it 'should give a X-Per-Page header' do
        headers_keys = last_response.headers.keys

        expect(headers_keys).not_to include('Per-Page')
        expect(headers_keys).to include('X-Per-Page')
        expect(per_page).to eq(10)
      end

      it 'should give a X-Page header' do
        headers_keys = last_response.headers.keys

        expect(headers_keys).to include('X-Page')
        expect(page).to eq(1)
      end
    end

    context 'configured not to include the total' do
      before { ApiPagination.config.include_total = false }

      it 'should not include a Total header' do
        get '/numbers', count: 10

        expect(last_response.header['Total']).to be_nil
      end

      it 'should not include a link with rel "last"' do
        get '/numbers', count: 100

        expect(link).to_not include('rel="last"')
      end

      after { ApiPagination.config.include_total = true }
    end

    context 'with query string including array parameter' do
      before do
        get '/numbers', { count: 100, parity: ['odd', 'even']}
      end

      it 'returns links with with same received parameters' do
        expect(links).to include('<http://example.org/numbers?count=100&page=10&parity%5B%5D=odd&parity%5B%5D=even>; rel="last"')
        expect(links).to include('<http://example.org/numbers?count=100&page=2&parity%5B%5D=odd&parity%5B%5D=even>; rel="next"')
      end
    end

    context 'request option to not include the total' do
      it 'should not include a Total header' do
        get '/numbers_with_inline_options', count: 10

        expect(last_response.header['Total']).to be_nil
      end

      it 'should not include a link with rel "last"' do
        get '/numbers_with_inline_options', count: 100

        expect(link).to_not include('rel="last"')
      end
    end

    context 'request option to change page_header' do
      it 'should give a X-Page header' do
        get '/numbers_with_inline_options', count: 10

        expect(last_response.headers.keys).to include('X-Page')
        expect(last_response.headers['X-Page'].to_i).to eq(1)
      end
    end
  end
end
