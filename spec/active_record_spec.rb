require 'spec_helper'
require 'support/active_record/foo'
require 'nulldb_rspec'

ActiveRecord::Base.establish_connection(
  adapter: :nulldb,
  schema: 'spec/support/active_record/schema.rb'
)

NullDB.configure { |ndb| def ndb.project_root; Dir.pwd; end; }

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

  context 'reflections' do
    it 'invokes the correct methods to determine type' do 
      expect(collection).to receive(:klass).at_least(:once)
                                           .and_call_original
      ApiPagination.paginate(collection)
    end

    it 'does not fail if table name is not snake cased class name' do
      allow(collection).to receive(:table_name).and_return(SecureRandom.uuid)
      expect { ApiPagination.paginate(collection) }.to_not raise_error
    end
  end
end


