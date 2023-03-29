require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Customer, type: :model do
  describe '#callback before_validation' do
    let!(:vendor1) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', code: 'PPH') }
    let!(:vendor2) { create(:cm_vendor_with_product, name: 'Siem Reap  Hotel') }
    let!(:customer1) { create(:cm_customer, vendor: vendor1)}
    let!(:customer2) { create(:cm_customer, email: 'jakemar@gmail.com', vendor: vendor1)}
    let!(:customer3) { create(:cm_customer, email: 'panhachom@gmail.com', vendor: vendor2)}


    context 'create customer number ' do
      it 'return customer increament by 1' do
        expect(customer1.customer_number).to eq 'PPH-000001'
        expect(customer2.customer_number).to eq 'PPH-000002'
      end

      it 'return first 3 letter of vendor_name if vendor_code is nil' do
        expect(customer3.customer_number).to eq 'SIE-000001'
      end

      it 'return 2 different customer from 2 different vendor' do
        expect(customer1.customer_number).to eq 'PPH-000001'
        expect(customer3.customer_number).to eq 'SIE-000001'
      end

      it 'return 2 different customer from 2 different vendor' do
        expect(customer1.customer_number).to eq 'PPH-000001'
        expect(customer3.customer_number).to eq 'SIE-000001'
      end
    end

  end
end