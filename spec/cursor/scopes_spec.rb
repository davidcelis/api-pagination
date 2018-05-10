require 'spec_helper'

if ApiPagination.config.paginator == :cursor

  shared_examples_for 'the first after page' do
    it { expect(subject.count).to eq(25) }
    it { expect(subject.first.text).to eq('tweet001') }
  end

  shared_examples_for 'the first before page' do
    it { expect(subject.count).to eq(25) }
    it { expect(subject.first.text).to eq('tweet100') }
  end

  shared_examples_for 'blank page' do
    it { expect(subject.count).to eq(0) }
  end

  describe Cursor::ActiveRecordExtension do
    before do
      1.upto(100) {|i| Tweet.create!(n: i, text: "tweet#{'%03d' % i}")}
    end

    [Tweet].each do |model_class|
      context "for #{model_class}" do
        describe '#page' do
          context 'page 1 after' do
            subject { model_class.cursor_page(after: 0) }
            it_should_behave_like 'the first after page'
          end

          context 'page 1 before' do
            subject { model_class.cursor_page(before: 101) }
            it_should_behave_like 'the first before page'
          end

          context 'page 2 after' do
            subject { model_class.cursor_page(after: 25) }
            it { expect(subject.count).to eq(25) }
            it { expect(subject.first.text).to eq('tweet026') }
          end

          context 'page 2 before' do
            subject { model_class.cursor_page(before: 75) }
            it { expect(subject.count).to eq(25) }
            it { expect(subject.first.text).to eq('tweet074') }
          end

          context 'page without an argument' do
            subject { model_class.cursor_page() }
            it_should_behave_like 'the first before page'
          end

          context 'after page < -1' do
            subject { model_class.cursor_page(after: -1) }
            it_should_behave_like 'the first after page'
          end

          context 'after page > max page' do
            subject { model_class.cursor_page(after: 1000) }
            it_should_behave_like 'blank page'
          end

          context 'before page < 0' do
            subject { model_class.cursor_page(before: 0) }
            it_should_behave_like 'blank page'
          end

          context 'before page > max page' do
            subject { model_class.cursor_page(before: 1000) }
            it_should_behave_like 'the first before page'
          end

          describe 'ensure #order_values is preserved' do
            subject { model_class.order('id').cursor_page() }
            it { expect(subject.order_values.uniq).to eq ["#{model_class.table_name}.id DESC"] }
          end
        end

        describe '#per' do
          context 'default page per 5' do
            subject { model_class.cursor_page.per(5) }
            it { expect(subject.count).to eq(5) }
            it { expect(subject.first.text).to eq('tweet100') }
          end

          context "default page per nil (using default)" do
            subject { model_class.cursor_page.per(nil) }
            it { expect(subject.count).to eq(model_class.default_per_page) }
          end
        end

        describe '#next_cursor' do

          context 'after 1st page' do
            subject { model_class.cursor_page(after: 0) }
            it { expect(subject.next_cursor).to eq(25) }
          end

          context 'after middle page' do
            subject { model_class.cursor_page(after: 50) }
            it { expect(subject.next_cursor).to eq(75) }
          end

          context 'before 1st page' do
            subject { model_class.cursor_page }
            it { expect(subject.next_cursor).to eq(76) }
          end

          context 'before middle page' do
            subject { model_class.cursor_page(before: 50) }
            it { expect(subject.next_cursor).to eq(25) }
          end

        end

        describe '#prev_cursor' do
          context 'after 1st page' do
            subject { model_class.cursor_page(after: 0) }
            it { expect(subject.prev_cursor).to eq(1) }
          end

          context 'after middle page' do
            subject { model_class.cursor_page(after: 50) }
            it { expect(subject.prev_cursor).to eq(51) }
          end

          context 'before 1st page' do
            subject { model_class.cursor_page }
            it { expect(subject.prev_cursor).to eq(100) }
          end

          context 'before middle page' do
            subject { model_class.cursor_page(before: 50) }
            it { expect(subject.prev_cursor).to eq(49) }
          end
        end
      end
    end
  end
end
