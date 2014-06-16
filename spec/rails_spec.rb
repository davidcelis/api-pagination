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
  end
end

describe NumbersResponderController, :type => :controller do
  before { request.host = 'example.org' }

  before do
    Rails.application.routes.draw do
      resources 'numbers', only: [:index], controller: 'numbers_responder'
    end
  end

  after do
    Rails.application.routes.draw do
      resources 'numbers', only: [:index], controller: 'numbers'
    end
  end

  describe 'GET #index' do
    let(:links) { response.headers['Link'].split(', ') }
    let(:total) { response.headers['Total'].to_i }

    context 'without enough items to give more than one page' do
      before { get :index, :count => 10, :format => 'json' }

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

    context 'with existing Link headers' do
      before { get :index, :count => 30, :with_headers => true, :format => 'json' }

      it_behaves_like 'an endpoint with existing Link headers', '.json'
    end

    context 'with enough items to paginate' do
      context 'when on the first page' do
        before { get :index, :count => 100, :format => 'json' }

        it_behaves_like 'an endpoint with a first page', '.json'
      end

      context 'when on the last page' do
        before { get :index, :count => 100, :page => 10, :format => 'json' }

        it_behaves_like 'an endpoint with a last page', '.json'
      end

      context 'when somewhere comfortably in the middle' do
        before { get :index, :count => 100, :page => 2, :format => 'json' }

        it_behaves_like 'an endpoint with a middle page', '.json'
      end
    end

  end
end


describe NumbersManipulatedController, :type => :controller do
  before { request.host = 'example.org' }

  before do
    Rails.application.routes.draw do
      resources 'numbers', only: [:index], controller: 'numbers_manipulated'
    end
  end

  after do
    Rails.application.routes.draw do
      resources 'numbers', only: [:index], controller: 'numbers'
    end
  end

  describe 'GET #index' do
    let(:links) { response.headers['Link'].split(', ') }
    let(:total) { response.headers['Total'].to_i }

    context 'without enough items to give more than one page' do
      before { get :index, :count => 10, :format => 'json' }

      it 'should list the manipulated numbers in the response body' do
        body = '["111","222","333","444","555","666","777","888","999","101010"]'
        expect(response.body).to eq(body)
      end
    end

  end
end






