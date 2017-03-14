require 'spec_helper'

if ApiPagination.config.paginator == :cursor

  require 'support/tweets_controller'
  require 'support/shared_examples/existing_headers'
  require 'support/shared_examples/first_page'
  require 'support/shared_examples/middle_page'
  require 'support/shared_examples/last_page'

  describe TweetsController, type: :controller do
    before do
      request.host = 'example.org'
    end

    describe 'GET #index' do
      let(:links) { response.headers['Link'].split(', ') }
      let(:total) { response.headers['Total'].to_i }
      let(:per_page) { response.headers['Per-Page'].to_i }

      context 'without enough items to give more than one page' do
        before { get :index, params: {count: 10} }

        it 'should give a Total header' do
          expect(total).to eq(10)
        end

        it 'should give a Per-Page header' do
          expect(per_page).to eq(10)
        end

        it 'should list all tweets in the response body' do
          body = (1..10).to_a.reverse
          expect(response_values('n')).to eq(body)
        end
      end

      context 'with existing Link headers' do
        before { Tweet.delete_all; get :index, params: {count: 30, with_headers: true} }

        it 'should keep existing Links' do
          expect(links).to include('<http://example.org/tweets?count=30>; rel="without"')
        end

        it 'should contain pagination Links' do
          expect(links).to include('<http://example.org/tweets?before=21&count=30&with_headers=true>; rel="next"')
        end

        it 'should give a Total header' do
          expect(total).to eq(30)
        end
      end

      context 'with enough items to paginate' do
        context 'when on the first page' do
          before { get :index, params: {count: 100} }

          it 'should give a link with rel "prev"' do
            expect(links).to include('<http://example.org/tweets?after=100&count=100>; rel="prev"')
          end

          it 'should give a link with rel "next"' do
            expect(links).to include('<http://example.org/tweets?before=91&count=100>; rel="next"')
          end

          it 'should give a Total header' do
            expect(total).to eq(100)
          end

          it 'should list the first page of tweets in the response body' do
            body = (91..100).to_a.reverse
            expect(response_values('n')).to eq(body)
          end
        end

        context 'when on the last page' do
          before { get :index, params: {count: 100, after: 90} }

          it 'should give a link with rel "next"' do
            expect(links).to include('<http://example.org/tweets?after=100&count=100>; rel="next"')
          end

          it 'should give a link with rel "prev"' do
            expect(links).to include('<http://example.org/tweets?before=91&count=100>; rel="prev"')
          end

          it 'should give a Total header' do
            expect(total).to eq(100)
          end

          it 'should list the last page of tweets in the response body' do
            body = (91..100).to_a
            expect(response_values('n')).to eq(body)
          end
        end

        context 'when somewhere comfortably in the middle' do
          before { get :index, params: {count: 100, before: 51} }

          it 'should give all pagination links' do
            expect(links).to include('<http://example.org/tweets?before=41&count=100>; rel="next"')
            expect(links).to include('<http://example.org/tweets?after=50&count=100>; rel="prev"')
          end

          it 'should give a Total header' do
            expect(total).to eq(100)
          end

          it 'should list a middle page of numbers in the response body' do
            body = (41..50).to_a.reverse
            expect(response_values('n')).to eq(body)
          end
        end
      end

      context 'providing a block' do
        it 'yields to the block instead of implicitly rendering' do
          get :index_with_custom_render, params: {count: 100}

          json = { tweets: (91..100).to_a.reverse.map { |n| { number: n } } }.to_json

          expect(response.body).to eq(json)
        end
      end

      context 'with scope' do
        let(:total_tweets) { 100 }
        before { get :index_with_scope, params: {count: total_tweets} }

        it 'should give a correct Total header' do
          expect(total).to eq(total_tweets / 2)
        end
      end

      context 'with custom response headers' do
        before do
          ApiPagination.config.total_header    = 'X-Total-Count'
          ApiPagination.config.per_page_header = 'X-Per-Page'
          ApiPagination.config.page_header     = 'X-Page'

          get :index, params: {count: 10}
        end

        after do
          ApiPagination.config.total_header    = 'Total'
          ApiPagination.config.per_page_header = 'Per-Page'
          ApiPagination.config.page_header     = nil
        end

        let(:total) { response.header['X-Total-Count'].to_i }
        let(:per_page) { response.header['X-Per-Page'].to_i }
        let(:page) { response.header['X-Page'].to_i }

        it 'should give a X-Total-Count header' do
          headers_keys = response.headers.keys

          expect(headers_keys).not_to include('Total')
          expect(headers_keys).to include('X-Total-Count')
          expect(total).to eq(10)
        end

        it 'should give a X-Per-Page header' do
          headers_keys = response.headers.keys

          expect(headers_keys).not_to include('Per-Page')
          expect(headers_keys).to include('X-Per-Page')
          expect(per_page).to eq(10)
        end
      end

      context 'configured not to include the total' do
        before { ApiPagination.config.include_total = false }

        it 'should not include a Total header' do
          get :index, params: {count: 10}

          expect(response.header['Total']).to be_nil
        end

        after { ApiPagination.config.include_total = true }
      end

      context 'custom per_page param' do
        context 'per_page_param as a symbol' do
          before do
            ApiPagination.config.per_page_param = :foo
          end

          after do
            ApiPagination.config.per_page_param = :per_page
          end

          it 'should work' do
            get :index_with_no_per_page, params: {foo: 2, count: 100}

            expect(response.header['Per-Page']).to eq('2')
          end
        end

        context 'page_param as a block' do
          before do
            ApiPagination.config.per_page_param do |params|
              params[:foo][:bar]
            end
          end

          after do
            ApiPagination.config.per_page_param = :per_page
          end

          it 'should work' do
            get :index_with_no_per_page, params: {foo: {bar: 2}, count: 100}

            expect(response.header['Per-Page']).to eq('2')
          end
        end
      end

      context 'default per page in model' do
        before do
          Tweet.class_eval do
            paginates_per 6
          end
        end

        after do
          Tweet.class_eval do
            paginates_per 25
          end
        end

        it 'should use default per page from model' do
          get :index_with_no_per_page, params: {count: 100}

          expect(response.header['Per-Page']).to eq(6)
        end

        it 'should not fail if model does not respond to per page' do
          Tweet.class_eval do
            paginates_per nil
          end

          get :index_with_no_per_page, params: {count: 100}

          expect(response.header['Per-Page']).to eq(Cursor.config.default_per_page)
        end
      end
    end
  end
end
