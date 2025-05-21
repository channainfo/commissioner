require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Customer, type: :model do
  describe '#callback before_validation' do
    let!(:vendor1) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', code: 'PPH') }
    let!(:place1) { create(:cm_place, code: 'KRS') }
    let!(:place2) { create(:cm_place, code: 'KSD') }
    let!(:place3) { create(:cm_place, code: 'KR') }
    let!(:customer1) { create(:cm_customer, place_id: place1.id , vendor: vendor1)}
    let!(:customer2) { create(:cm_customer, place_id: place1.id, email: 'panhachom@gmail.com', vendor: vendor1)}


    context 'create customer number ' do
      it 'return customer increament by 1' do
        customer3 = SpreeCmCommissioner::Customer.create(vendor_id: vendor1.id, place_id: place1.id)

        expect(customer1.number).to eq 'KRS-000001'
        expect(customer2.number).to eq 'KRS-000002'
        expect(customer3.number).to eq 'KRS-000003'
      end
    end

    it "change customer number if location is change" do
      customer1.update(place_id: place2.id)
      customer2.update(place_id: place2.id)

      customer1.update_number
      customer2.update_number

      expect(customer1.number).to eq 'KSD-000001'
      expect(customer2.number).to eq 'KSD-000002'
    end

    it 'return customer number starts from 1 if there is no customer with the same location' do
      customer4 = SpreeCmCommissioner::Customer.create(vendor_id: vendor1.id, place_id: place3.id)
      expect(customer4.number).to eq 'KR-000001'
    end
  end

  describe '#subscribable_variants' do
    let!(:vendor) { create(:vendor) }

    let(:taxon1) { create(:taxon) }
    let(:taxon2) { create(:taxon) }

    let!(:place1) { create(:cm_place, name: 'KRS') }

    let!(:customer1) { create(:cm_customer, vendor: vendor, place_id: place1.id) }
    let!(:customer2) { create(:cm_customer, vendor: vendor, place_id: place1.id) }

    before do
      create(:cm_customer_taxon, customer: customer1, taxon: taxon1)
      create(:cm_customer_taxon, customer: customer2, taxon: taxon2)

      product1 = create(:cm_product, vendor: vendor, subscribable: true)
      product2 = create(:cm_product, vendor: vendor, subscribable: true)

      product1.taxons = [taxon1]
      product2.taxons = [taxon2]

      create_list(:variant, 2, product: product1)
      create_list(:variant, 2, product: product2)
    end

    it "returns all product's variants that have the same taxon as the customer" do
      variants_list1 = customer1.subscribable_variants
      variants_list2 = customer2.subscribable_variants

      expect(variants_list1.size).to eq 2
      expect(variants_list2.size).to eq 2

      expect(variants_list1).to include(*customer1.variants)
      expect(variants_list2).to include(*customer2.variants)
    end
  end
end