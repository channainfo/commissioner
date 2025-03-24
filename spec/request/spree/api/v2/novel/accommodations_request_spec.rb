require 'spec_helper'

describe 'API::V2::Novel::Storefront::AccommodationsController', type: :request do
  let(:today) { Date.today }
  let(:tomorrow) { today + 1 }
  let(:json_response) { JSON.parse(response.body) }

  # Create provinces
  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let(:siem_reap)  { create(:state, name: 'Siem Reap') }

  describe 'Get #index' do
    # Create vendors
    let!(:vendor1) {  create(:cm_vendor, name: 'Phnom Penh Hotel', default_state_id: phnom_penh.id, primary_product_type: :accommodation, state: :active) }
    let!(:vendor2) {  create(:cm_vendor, name: 'Sokha Phnom Penh Hotel', default_state_id: phnom_penh.id, primary_product_type: :accommodation, state: :active) }
    let!(:vendor3) {  create(:cm_vendor, name: 'Angkor Hotel', default_state_id: siem_reap.id, primary_product_type: :accommodation, state: :active) }
    let!(:vendor4) {  create(:cm_vendor, name: 'Domrey Anngor Hotel', default_state_id: siem_reap.id, primary_product_type: :accommodation, state: :active) }

    # Create variant
    let(:variant1) { create(:variant, vendor: vendor1) }
    let(:variant2) { create(:variant, vendor: vendor2) }
    let(:variant3) { create(:variant, vendor: vendor3) }
    let(:variant4) { create(:variant, vendor: vendor4) }

    before do
      # Inventory setup for each variant (1 unit is inventory for 1 day)
      create(:cm_inventory_unit, variant: variant1, inventory_date: today, quantity_available: 2, max_capacity: 3)
      create(:cm_inventory_unit, variant: variant1, inventory_date: tomorrow, quantity_available: 2, max_capacity: 3)

      create(:cm_inventory_unit, variant: variant2, inventory_date: today, quantity_available: 1, max_capacity: 3)
      create(:cm_inventory_unit, variant: variant2, inventory_date: tomorrow, quantity_available: 1, max_capacity: 3)

      create(:cm_inventory_unit, variant: variant3, inventory_date: today, quantity_available: 2, max_capacity: 3)
      create(:cm_inventory_unit, variant: variant3, inventory_date: tomorrow, quantity_available: 3, max_capacity: 3)

      create(:cm_inventory_unit, variant: variant4, inventory_date: today, quantity_available: 2, max_capacity: 3)
      create(:cm_inventory_unit, variant: variant4, inventory_date: tomorrow, quantity_available: 1, max_capacity: 3)
    end

    context 'with 1 guest, 2 nights in Phnom Penh' do
      let(:params) {{ from_date: today, to_date: tomorrow + 1, province_id: phnom_penh.id, num_guests: 1 }}

      it 'returns all phnom penh hotels' do
        get '/api/v2/novel/storefront/accommodations', params: params

        expect(json_response["data"].pluck("id")).to eq(["#{vendor1.id}", "#{vendor2.id}"])
      end
    end

    context 'with 1 guest, 3 nights in Phnom Penh' do
      let(:params) {{ from_date: today, to_date: tomorrow + 2, province_id: phnom_penh.id, num_guests: 1 }}

      it 'returns empty array when no availability' do
        get '/api/v2/novel/storefront/accommodations', params: params

        expect(json_response["meta"]["count"]).to eq 0
      end
    end

    context 'with 2 guests, 2 nights in Siem Reap' do
      let(:params) {{ from_date: today, to_date: tomorrow + 1, province_id: siem_reap.id, num_guests: 2 }}

      it 'returns only Angkor Hotel' do
        get '/api/v2/novel/storefront/accommodations', params: params

        expect(json_response["data"].pluck("id")).to eq(["#{vendor3.id}"])
      end
    end

    context 'with 2 guests, 1 night in Siem Reap' do
      let(:params) {{ from_date: today, to_date: tomorrow, province_id: siem_reap.id, num_guests: 2 }}

      it 'returns both Siem Reap hotels' do
        get '/api/v2/novel/storefront/accommodations', params: params

        expect(json_response["data"].pluck("id")).to eq(["#{vendor3.id}", "#{vendor4.id}"])
      end
    end
  end

  describe 'Get #show' do
    # Create vendor
    let!(:vendor1) {  create(:cm_vendor, name: 'Phnom Penh Hotel', default_state_id: phnom_penh.id, primary_product_type: :accommodation, state: :active) }
    let!(:vendor2) {  create(:cm_vendor, name: 'Sokha Phnom Penh Hotel', default_state_id: phnom_penh.id, primary_product_type: :accommodation, state: :active) }

    # Create variant
    let(:variant1) { create(:variant, vendor: vendor1) }
    let(:variant2) { create(:variant, vendor: vendor2) }

    before do
      # Inventory setup for each variant (1 unit is inventory for 1 day)
      create(:cm_inventory_unit, variant: variant1, inventory_date: today, quantity_available: 2, max_capacity: 3)
      create(:cm_inventory_unit, variant: variant1, inventory_date: tomorrow, quantity_available: 2, max_capacity: 3)

      create(:cm_inventory_unit, variant: variant2, inventory_date: today, quantity_available: 1, max_capacity: 3)
      create(:cm_inventory_unit, variant: variant2, inventory_date: tomorrow, quantity_available: 1, max_capacity: 3)
    end

    context "when the vendor's is available" do
      before { get "/api/v2/novel/storefront/accommodations/#{vendor1.slug}", params: { include: 'logo,variants', from_date: today, to_date: tomorrow} }

      it 'should return json with stock information' do
        expect(json_response['data']['id']).to eq("#{vendor1.id}")
      end
    end

    context "when the vendor's is not available" do
      before { get "/api/v2/novel/storefront/accommodations/#{vendor2.slug}", params: { include: 'logo,variants', from_date: today, to_date: tomorrow + 3} }

      it 'should return json with stock information' do
        expect(json_response["error"]).to eq("The resource you were looking for could not be found.")
      end
    end
  end
end
