require 'spec_helper'

RSpec.describe Spree::Transit::PlacesController, type: :controller do
  describe '#create_places_taxon' do
    context 'when the Places taxonomy and return it' do
      it 'creates a Places taxonomy and returns it' do
        expect(Spree::Taxonomy.find_by(name: 'Places')).to be_nil

        created_taxonomy = controller.create_places_taxon

        expect(created_taxonomy).to be_a(Spree::Taxonomy)
        expect(created_taxonomy.name).to eq('Places')
        expect(created_taxonomy.kind).to eq('transit')
        expect(created_taxonomy.store).to eq(controller.current_store)
      end
    end

    context 'when the Places taxonomy already exists' do
      let(:places_taxonomy ) { create(:taxonomy, name: 'Places', kind: "transit") }
      it 'returns the existing Places taxonomy' do
        existing_taxonomy  = places_taxonomy
        returned_taxonomy = controller.load_places_taxonomy

        expect(returned_taxonomy).to eq(existing_taxonomy)
      end
    end

  end
end