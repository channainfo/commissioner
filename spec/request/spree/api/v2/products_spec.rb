require 'spec_helper'

describe 'API V2 Storefront Product Spec', type: :request do
  describe 'products#show' do  
    context 'for master option types' do
      let!(:product) { create(:cm_product_with_master_option_types) }
      let!(:includes) { ["master_option_types", "primary_variant", "primary_variant.option_values"] }

      before { get "/api/v2/storefront/products/#{product.slug}?include=#{includes.join(",")}" }
      it_behaves_like 'returns 200 HTTP status'

      it 'return master_option_types & primary_variant along with product' do
        expect(json_response_body['data']['relationships']['master_option_types']['data'].size).to eq 1
        expect(json_response_body['data']['relationships']['primary_variant']['data']['id']).to eq product.master.id.to_s
      end

      it 'return master_option_types inside [included]' do
        included_option_types = json_response_body['included'].select {|e| e['type'] == "option_type"}
        master_option_types = json_response_body['data']['relationships']['master_option_types']['data']

        expect(included_option_types.size).to eq 1
        expect(master_option_types.size).to eq 1

        expect(included_option_types[0]['id']).to eq master_option_types[0]['id']
      end

      it 'return primary_variant inside [included]' do
        included_variants = json_response_body['included'].select {|e| e['type'] == "variant"}
        primary_variant = json_response_body['data']['relationships']['primary_variant']['data']

        expect(included_variants.size).to eq 1
        expect(included_variants[0]['id']).to eq primary_variant['id']
      end

      it 'return primary_variant.option_values inside [included]' do
        option_values = json_response_body['included'].select {|e| e['type'] == "option_value"}
        expect(option_values.size).to eq 2
      end
    end
  end
end
