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
    let(:per_page) { response.headers['Per-Page'].to_i }

    context 'without enough items to give more than one page' do
      before { get :index, :count => 10 }

      it 'should not paginate' do
        expect(response.headers.keys).not_to include('Link')
      end

      it 'should give a Total header' do
        expect(total).to eq(10)
      end

      it 'should give a Per-Page header' do
        expect(per_page).to eq(10)
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

    context 'providing a block' do
      it 'yields to the block instead of implicitly rendering' do
        get :index_with_custom_render, :count => 100

        json = { numbers: (1..10).map { |n| { number: n } } }.to_json

        expect(response.body).to eq(json)
      end
    end

    context 'with custom response headers' do
      before do
        ApiPagination.config.total_header    = 'X-Total-Count'
        ApiPagination.config.per_page_header = 'X-Per-Page'
        ApiPagination.config.page_header     = 'X-Page'

        get :index, count: 10
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

      it 'should give a X-Page header' do
        headers_keys = response.headers.keys

        expect(headers_keys).to include('X-Page')
        expect(page).to eq(1)
      end
    end

    context 'configured not to include the total' do
      before { ApiPagination.config.include_total = false }

      it 'should not include a Total header' do
        get :index, count: 10

        expect(response.header['Total']).to be_nil
      end

      after { ApiPagination.config.include_total = true }
    end

    context 'custom page param' do
      context 'page_param as a symbol' do
        before do
          ApiPagination.config.page_param = :foo
          ApiPagination.config.page_header = 'Page'
        end

        after do
          ApiPagination.config.page_param = :page
          ApiPagination.config.page_header = nil
        end

        it 'should work' do
          get :index, :foo => 2, :count => 100

          expect(response.header['Page']).to eq('2')
        end
      end

      context 'page_param as a block' do
        before do
          ApiPagination.config.page_param do |params|
            params[:foo][:bar]
          end

          ApiPagination.config.page_header = 'Page'
        end

        after do
          ApiPagination.config.page_param = :page
          ApiPagination.config.page_header = nil
        end

        it 'should work' do
          get :index, :foo => { :bar => 2 }, :count => 100

          expect(response.header['Page']).to eq('2')
        end
      end
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
          get :index_with_no_per_page, :foo => 2, :count => 100

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
          get :index_with_no_per_page, :foo => { :bar => 2 }, :count => 100

          expect(response.header['Per-Page']).to eq('2')
        end
      end
    end

    context 'default per page in model' do
      before do
        class Fixnum
          @default_per_page = 6
          @per_page = 6

          class << self
            attr_accessor :default_per_page, :per_page
          end
        end
      end

      after do
        class Fixnum
          @default_per_page = 25
          @per_page = 25
        end
      end

      it 'should use default per page from model' do
        get :index_with_no_per_page, count: 100

        expect(response.header['Per-Page']).to eq('6')
      end

      it 'should not fail if model does not respond to per page' do
        class Fixnum
          @default_per_page = nil
          @per_page = nil
        end

        get :index_with_no_per_page, count: 100

        expect(response.header['Per-Page']).to eq(
          case ApiPagination.config.paginator
          when :kaminari      then Kaminari.config.default_per_page.to_s
          when :will_paginate then WillPaginate.per_page.to_s
          end
        )
      end
    end
  end
end
