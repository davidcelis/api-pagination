require 'spec_helper'
require 'support/shared_examples/existing_headers'
require 'support/shared_examples/first_page'
require 'support/shared_examples/middle_page'
require 'support/shared_examples/last_page'

describe NumbersAPI do
  describe 'GET #index' do
    let(:links) { last_response.headers['Link'].split(', ') }

    context 'without enough items to give more than one page' do
      it 'should not paginate' do
        get :numbers, :count => 20
        expect(last_response.headers.keys).not_to include('Link')
      end
    end

    context 'with existing Link headers' do
      before { get :numbers, :count => 30, :with_headers => true }

      it_behaves_like 'an endpoint with existing Link headers'
    end

    context 'with enough items to paginate' do
      context 'when on the first page' do
        before { get :numbers, :count => 100 }

        it_behaves_like 'an endpoint with a first page'
      end

      context 'when on the last page' do
        before { get :numbers, :count => 100, :page => 4 }

        it_behaves_like 'an endpoint with a last page'
      end

      context 'when somewhere comfortably in the middle' do
        before { get :numbers, :count => 100, :page => 2 }

        it_behaves_like 'an endpoint with a middle page'
      end
    end
  end
end
