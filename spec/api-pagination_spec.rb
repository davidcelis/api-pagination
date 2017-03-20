require 'spec_helper'

describe ApiPagination do
  let(:collection) { (1..100).to_a }
  let(:paginate_array_options) { { total_count: 1000 } }

  context 'Using kaminari' do
    before do
      ApiPagination.config.paginator = :kaminari
    end

    after do
      ApiPagination.config.paginator = ENV.fetch('PAGINATOR', 'kaminari').to_sym
    end

    it 'should accept paginate_array_options option' do
      expect(Kaminari).to receive(:paginate_array)
                            .with(collection, paginate_array_options)
                            .and_call_original

      ApiPagination.paginate(
        collection,
        {
          per_page: 30,
          paginate_array_options: paginate_array_options
        }
      )
    end

    describe '.pages_from' do
      subject { described_class.pages_from collection }

      context 'on empty collection' do
        let(:collection) { ApiPagination.paginate [], page: 1 }

        it { is_expected.to be_empty }
      end
    end
  end
end
