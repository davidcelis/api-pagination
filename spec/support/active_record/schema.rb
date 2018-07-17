ActiveRecord::Schema.define(version: 0) do
  create_table "foos", :force => true do |t|
    t.string   "foo"
  end
end