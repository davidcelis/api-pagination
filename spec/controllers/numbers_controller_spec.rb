require 'spec_helper'

Rails.application.routes.draw do
  resources :numbers, only: [:index]
end

# quacks like Kaminari
PaginatedSet = Struct.new(:current_page, :total_count) do
  def limit_value() 25 end

  def total_pages
    total_count.zero? ? 1 : (total_count.to_f / limit_value).ceil
  end

  def first_page?() current_page == 1 end
  def last_page?() current_page == total_pages end
end

class NumbersController < ActionController::Base
  include Rails.application.routes.url_helpers

  after_filter only: [:index] { paginate(:numbers) }

  def index
    page = params.fetch(:page, 1).to_i
    total = params.fetch(:count).to_i
    @numbers = PaginatedSet.new(page, total)
    render json: @numbers
  end
end

describe NumbersController, :type => :controller do
  describe 'GET #index' do
    context 'without enough items to give more than one page' do
      it 'should not paginate' do
        get :index, count: 20
        response.headers['Link'].should be_blank
      end
    end

    context 'with enough items to paginate' do
      context 'when on the first page' do
        before(:each) do
          get :index, count: 100

          @links = response.headers['Link'].split(', ')
        end

        it 'should not give a link with rel "first"' do
          @links.should_not include('rel="first"')
        end

        it 'should not give a link with rel "prev"' do
          @links.should_not include('rel="prev"')
        end

        it 'should give a link with rel "last"' do
          @links.should include('<http://test.host/numbers?count=100&page=4>; rel="last"')
        end

        it 'should give a link with rel "next"' do
          @links.should include('<http://test.host/numbers?count=100&page=2>; rel="next"')
        end
      end

      context 'when on the last page' do
        before(:each) do
          get :index, count: 100, page: 4

          @links = response.headers['Link'].split(', ')
        end

        it 'should not give a link with rel "last"' do
          @links.should_not include('rel="last"')
        end

        it 'should not give a link with rel "next"' do
          @links.should_not include('rel="next"')
        end

        it 'should give a link with rel "first"' do
          @links.should include('<http://test.host/numbers?count=100&page=1>; rel="first"')
        end

        it 'should give a link with rel "prev"' do
          @links.should include('<http://test.host/numbers?count=100&page=3>; rel="prev"')
        end
      end

      context 'when somewhere comfortably in the middle' do
        it 'should give all pagination links' do
          get :index, count: 100, page: 2

          links = response.headers['Link'].split(', ')

          links.should include('<http://test.host/numbers?count=100&page=1>; rel="first"')
          links.should include('<http://test.host/numbers?count=100&page=4>; rel="last"')
          links.should include('<http://test.host/numbers?count=100&page=3>; rel="next"')
          links.should include('<http://test.host/numbers?count=100&page=1>; rel="prev"')
        end
      end
    end
  end
end





