require 'spec_helper'
require 'support/active_record/foo'
require 'nulldb_rspec'

ActiveRecord::Base.establish_connection(
  adapter: :nulldb,
  schema: 'support/active_record/schema'
)

shared_examples 'produces_correct_sql' do 
  let(:collection) { Foo.all }
  let(:per_page) { 5 }

  it 'produces correct sql for first page' do
    paginated_sql = ApiPagination.paginate(collection, per_page: per_page)
                                 .to_sql
    expect(paginated_sql).to eql(Foo.limit(per_page).offset(0).to_sql)
  end
end

if ApiPagination.config.paginator == :kaminari
  describe 'pagination with kaminari' do
    before do 
      ApiPagination.config.paginator = :kaminari
    end

    include_examples 'produces_correct_sql'
  end
end

if ApiPagination.config.paginator == :will_paginate
  require 'will_paginate/active_record'

  describe 'pagination with will_paginate' do 
    before do 
      ApiPagination.config.paginator = :will_paginate
    end

    include_examples 'produces_correct_sql'
  end
end