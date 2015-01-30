require 'spec_helper'

if ApiPagination.config.paginator == :will_paginate
  require 'sqlite3'
  require 'sequel'
  require 'will_paginate/sequel'

  DB = Sequel.sqlite
  DB.extension :pagination
  DB.create_table :people do
    primary_key :id
    String :name
  end

  describe 'Using will_paginate with Sequel' do
    let(:people) do
      DB[:people]
    end

    before(:each) do
      people.insert(name: 'John')
      people.insert(name: 'Mary')
    end

    it 'returns a Sequel::Dataset' do
      collection = ApiPagination.paginate(people)
      expect(collection.kind_of?(Sequel::Dataset)).to be_truthy
    end
  end
end

