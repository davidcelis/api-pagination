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
    allow(collection).to receive(:count).and_return(collection_size)
    paginated_sql, _ = ApiPagination.paginate(collection, per_page: per_page)
    expect(paginated_sql.to_sql).to eql(Foo.limit(per_page).offset(0).to_sql)
  end
end

describe 'ActiveRecord Support' do 
  let(:collection) { Foo.all }
  let(:collection_size) { 50 }
  let(:per_page) { 5 }
  
  if ApiPagination.config.paginator == :will_paginate
    require 'will_paginate/active_record'
  end

  context "pagination with #{ApiPagination.config.paginator}" do 
    include_examples 'produces_correct_sql'
  end


  if ApiPagination.config.paginator != :pagy
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
end


