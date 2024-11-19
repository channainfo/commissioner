require 'spec_helper'

RSpec.describe Spree::V2::Storefront::TaxonSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:category_icon) { create(:cm_taxon_category_icon) }
    let!(:taxon) { create(:taxon, category_icon: category_icon) }
    let!(:home_banner) { create(:cm_asset, viewable: taxon) }

    subject {
      described_class.new(taxon, include: [
        :parent,
        :taxonomy,
        :children,
        :image,
        :category_icon,
        :app_banner,
        :web_banner,
        :home_banner,
        :vendors,
        :visible_products,
      ]).serializable_hash
    }

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
        :is_root,
        :is_child,
        :is_leaf,
        :custom_redirect_url,
        :kind,
        :subtitle,
        :from_date,
        :to_date,
        :background_color,
        :foreground_color,
        :show_badge_status,
        :purchasable_on,
        :purchasable_on_app,
        :purchasable_on_web
      )
    end

    it 'returns exact taxon relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :parent,
        :taxonomy,
        :children,
        :image,
        :category_icon,
        :app_banner,
        :web_banner,
        :home_banner,
        :vendors,
        :visible_products,
      )
    end
  end
end
