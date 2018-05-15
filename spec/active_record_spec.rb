require 'spec_helper'
require 'support/active_record/foo'
require 'nulldb_rspec'

ActiveRecord::Base.establish_connection(
  adapter: :nulldb,
  schema: 'support/active_record/schema'
)

describe 'using kaminari with active_record' do
  let(:collection) { Foo.all }
  let(:per_page) { 5 }

  it 'produces correct sql for first page' do
    paginated_sql = ApiPagination.paginate(collection, per_page: per_page)
                                 .to_sql

    expect(paginated_sql).to eql(Foo.limit(per_page).offset(0).to_sql)
  end
end