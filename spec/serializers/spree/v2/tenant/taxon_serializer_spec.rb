require 'spec_helper'

RSpec.describe Spree::V2::Tenant::TaxonSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:taxon) { create(:taxon) }

    subject { described_class.new(taxon, params: { include_products: true }).serializable_hash }

    it 'returns exact taxon attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :pretty_name,
        :permalink,
        :seo_title,
        :description,
        :meta_title,
        :meta_description,
        :meta_keywords,
        :left,
        :right,
        :position,
        :depth,
        :updated_at,
        :public_metadata,
        :custom_redirect_url,
        :kind,
        :subtitle,
        :from_date,
        :to_date,
        :background_color,
        :foreground_color,
        :show_badge_status,
        :purchasable_on,
        :is_root,
        :is_child,
        :is_leaf
      )
    end

    it 'returns correct values for taxon attributes' do
      expect(subject[:data][:attributes][:name]).to eq(taxon.name)
      expect(subject[:data][:attributes][:pretty_name]).to eq(taxon.pretty_name)
      expect(subject[:data][:attributes][:permalink]).to eq(taxon.permalink)
      expect(subject[:data][:attributes][:seo_title]).to eq(taxon.seo_title)
      expect(subject[:data][:attributes][:description]).to eq(taxon.description)
      expect(subject[:data][:attributes][:meta_title]).to eq(taxon.meta_title)
      expect(subject[:data][:attributes][:meta_description]).to eq(taxon.meta_description)
      expect(subject[:data][:attributes][:meta_keywords]).to eq(taxon.meta_keywords)
      expect(subject[:data][:attributes][:left]).to eq(taxon.left)
      expect(subject[:data][:attributes][:right]).to eq(taxon.right)
      expect(subject[:data][:attributes][:position]).to eq(taxon.position)
      expect(subject[:data][:attributes][:depth]).to eq(taxon.depth)
      expect(subject[:data][:attributes][:updated_at]).to eq(taxon.updated_at)
      expect(subject[:data][:attributes][:public_metadata]).to eq(taxon.public_metadata)
      expect(subject[:data][:attributes][:custom_redirect_url]).to eq(taxon.custom_redirect_url)
      expect(subject[:data][:attributes][:kind]).to eq(taxon.kind)
      expect(subject[:data][:attributes][:subtitle]).to eq(taxon.subtitle)
      expect(subject[:data][:attributes][:from_date]).to eq(taxon.from_date)
      expect(subject[:data][:attributes][:to_date]).to eq(taxon.to_date)
      expect(subject[:data][:attributes][:background_color]).to eq(taxon.background_color)
      expect(subject[:data][:attributes][:foreground_color]).to eq(taxon.foreground_color)
      expect(subject[:data][:attributes][:show_badge_status]).to eq(taxon.show_badge_status)
      expect(subject[:data][:attributes][:purchasable_on]).to eq(taxon.purchasable_on)
      expect(subject[:data][:attributes][:is_root]).to eq(taxon.root?)
      expect(subject[:data][:attributes][:is_child]).to eq(taxon.child?)
      expect(subject[:data][:attributes][:is_leaf]).to eq(taxon.leaf?)
    end

    it 'includes associated objects' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :category_icon,
        :app_banner,
        :web_banner,
        :home_banner,
        :parent,
        :taxonomy,
        :children
      )
    end
  end
end
