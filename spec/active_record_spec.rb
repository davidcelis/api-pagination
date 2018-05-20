require 'spec_helper'
require 'support/active_record/foo'
require 'nulldb_rspec'

ActiveRecord::Base.establish_connection(
  adapter: :nulldb,
  schema: 'support/active_record/schema'
)

shared_examples 'produces_correct_sql' do 
  it 'produces correct sql for first page' do
    paginated_sql = ApiPagination.paginate(collection, per_page: per_page)
    .to_sql
    expect(paginated_sql).to eql(Foo.limit(per_page).offset(0).to_sql)
  end
end

describe 'ActiveRecord Support' do 
  let(:collection) { Foo.all }
  let(:per_page) { 5 }

  if ApiPagination.config.paginator == :kaminari
    context 'pagination with kaminari' do
      before { ApiPagination.config.paginator = :kaminari }
      include_examples 'produces_correct_sql'
    end
  end
  
  if ApiPagination.config.paginator == :will_paginate
    require 'will_paginate/active_record'
  
    context 'pagination with will_paginate' do 
      before { ApiPagination.config.paginator = :will_paginate }
      include_examples 'produces_correct_sql'
    end
  end

  context 'reification' do
    before do 
      allow(collection).to receive(:table_name).and_return('aaBB_CC_DD')
    end

    it 'correctly produces the correct model independent of table name' do 
      expect { ApiPagination.paginate(collection) }.not_to raise_error
    end
  end
end


