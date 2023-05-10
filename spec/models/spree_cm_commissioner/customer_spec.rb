require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Customer, type: :model do
  describe '#callback before_validation' do
    let!(:vendor1) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', code: 'PPH') }
    let!(:vendor2) { create(:cm_vendor_with_product, name: 'Siem Reap  Hotel') }
    let!(:customer1) { create(:cm_customer, vendor: vendor1)}
    let!(:customer3) { create(:cm_customer, email: 'panhachom@gmail.com', vendor: vendor2)}


    context 'create customer number ' do
      it 'return customer increament by 1' do
        customer2 = SpreeCmCommissioner::Customer.create(vendor_id: vendor1.id)
        expect(customer1.number).to eq 'PPH-000001'
        expect(customer2.number).to eq 'PPH-000002'
      end
    end

      it "change customer number if vendor_code is change" do
        vendor10 = Spree::Vendor.create(name: 'PhnomPenh Angkor',code: "PHN")
        customer10 = SpreeCmCommissioner::Customer.create!(vendor_id: vendor10.id)
        customer20 = SpreeCmCommissioner::Customer.create(vendor_id: vendor10.id)
        vendor10.reload
        vendor10.update(code: 'PPP')
        vendor10.reload
        expect(customer10.reload.number).to eq 'PPP-000001'
        expect(customer20.reload.number).to eq 'PPP-000002'
        vendor10.update(code: 'PPH')
        vendor10.reload
        expect(customer10.reload.number).to eq 'PPH-000001'
        expect(customer20.reload.number).to eq 'PPH-000002'
      end

      it 'return first 3 letter of vendor_name if vendor_code is nil' do
        expect(customer3.number).to eq 'SIE-000001'
      end

      it 'return 2 different customer from 2 different vendor' do
        expect(customer1.number).to eq 'PPH-000001'
        expect(customer3.number).to eq 'SIE-000001'
      end

      it 'return 2 different customer from 2 different vendor' do
        expect(customer1.number).to eq 'PPH-000001'
        expect(customer3.number).to eq 'SIE-000001'
      end
  end

  describe '#subscribable_variants' do
    let!(:vendor) { create(:vendor) }

    let(:taxon1) { create(:taxon) }
    let(:taxon2) { create(:taxon) }

    let!(:customer1) { create(:cm_customer, taxon_id: taxon1.id, vendor: vendor) }

    let(:product1) { create(:product, vendor: customer1.vendor,subscribable: true) }

    it "return all product's variants that has the same taxon as customer" do
      vendor.reload
      customer2 = create(:cm_customer, taxon_id: taxon2.id, vendor: vendor)
      product2 =  create(:product, vendor: customer2.vendor,subscribable: true)

      product1.taxons = [taxon1]
      product2.taxons = [taxon2]

      variant11 = create(:variant, product: product1)
      variant12 = create(:variant, product: product1)
      variant21 = create(:variant, product: product2)
      variant22 = create(:variant, product: product2)

      variants_list1 = customer1.subscribable_variants
      variants_list2 = customer2.subscribable_variants

      expect(variants_list1.size).to eq 2
      expect(variants_list2.size).to eq 2

      expect(variants_list1).to include(variant11)
      expect(variants_list1).to include(variant12)

      expect(variants_list2).to include(variant21)
      expect(variants_list2).to include(variant22)
    end
  end
end