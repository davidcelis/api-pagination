require 'spec_helper'
require 'support/shared_examples/existing_headers'
require 'support/shared_examples/first_page'
require 'support/shared_examples/middle_page'
require 'support/shared_examples/last_page'

describe NumbersController, :type => :controller do
  before { request.host = 'example.org' }

  describe 'GET #index' do
    let(:links) { response.headers['Link'].split(', ') }
    let(:total) { response.headers['Total'].to_i }

    context 'without enough items to give more than one page' do
      before { get :index, :count => 10 }

      it 'should not paginate' do
        expect(response.headers.keys).not_to include('Link')
      end

      it 'should give a Total header' do
        expect(total).to eq(10)
      end

      it 'should list all numbers in the response body' do
        body = '[1,2,3,4,5,6,7,8,9,10]'
        expect(response.body).to eq(body)
      end
    end

    context 'with per_page larger than max_per_page' do
      before { get :index, :count => 100, :per_page => 50 }

      it 'should only return max_per_page items' do
        expect(response.body).to eq('[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]')
      end

      it 'should correct the per_page parameter in links' do
        expect(links).to include('<http://example.org/numbers?count=100&page=5&per_page=20>; rel="last"')
      end
    end

    context 'with existing Link headers' do
      before { get :index, :count => 30, :with_headers => true }

      it_behaves_like 'an endpoint with existing Link headers'
    end

    context 'with enough items to paginate' do
      context 'when on the first page' do
        before { get :index, :count => 100 }

        it_behaves_like 'an endpoint with a first page'
      end

      context 'when on the last page' do
        before { get :index, :count => 100, :page => 10 }

        it_behaves_like 'an endpoint with a last page'
      end

      context 'when somewhere comfortably in the middle' do
        before { get :index, :count => 100, :page => 2 }

        it_behaves_like 'an endpoint with a middle page'
      end
    end

    context 'providing a block' do
      it 'yields to the block instead of implicitly rendering' do
        get :index_with_custom_render, :count => 100

        json = { numbers: (1..10).map { |n| { number: n } } }.to_json

        expect(response.body).to eq(json)
      end
    end
  end
end





