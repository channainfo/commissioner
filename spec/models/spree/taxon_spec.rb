require 'spec_helper'

RSpec.describe Spree::Taxon, type: :model do
  describe 'associations' do
    it { should have_many(:taxon_vendors).class_name('SpreeCmCommissioner::TaxonVendor') }
    it { should have_many(:vendors).through(:taxon_vendors) }
    it { should have_many(:guest_card_classes).class_name('SpreeCmCommissioner::GuestCardClass') }
    it { should have_many(:homepage_section_relatables).dependent(:destroy).class_name('SpreeCmCommissioner::HomepageSectionRelatable') }
    it { should have_many(:user_events).class_name('SpreeCmCommissioner::UserEvent') }
    it { should have_many(:users).through(:user_events).class_name(Spree.user_class.to_s) }
    it { should have_many(:products).through(:classifications).class_name('Spree::Product') }
    it { should have_many(:guests).dependent(:nullify).class_name('SpreeCmCommissioner::Guest') }
    it { should have_many(:check_ins).dependent(:nullify).class_name('SpreeCmCommissioner::CheckIn') }
    it { should have_many(:customer_taxons).class_name('SpreeCmCommissioner::CustomerTaxon') }
    it { should have_one(:category_icon).dependent(:destroy).class_name('SpreeCmCommissioner::TaxonCategoryIcon') }
    it { should have_one(:web_banner).dependent(:destroy).class_name('SpreeCmCommissioner::TaxonWebBanner') }
    it { should have_one(:app_banner).dependent(:destroy).class_name('SpreeCmCommissioner::TaxonAppBanner') }
    it { should have_one(:home_banner).dependent(:destroy).class_name('SpreeCmCommissioner::TaxonHomeBanner') }
    it { should have_many(:notification_taxons).class_name('SpreeCmCommissioner::NotificationTaxon') }
    it { should have_many(:customer_notifications).through(:notification_taxons).class_name('SpreeCmCommissioner::CustomerNotification') }
    it { should have_many(:visible_classifications).class_name('Spree::Classification') }
    it { should have_many(:visible_products).through(:visible_classifications).class_name('Spree::Product') }
  end

  describe 'reposition children awesome_nested_set' do
    let(:taxonomy) { create(:taxonomy) }
    let(:parent_taxon) { create(:taxon, taxonomy: taxonomy) }
    let(:child1) { create(:taxon, taxonomy: taxonomy, parent: parent_taxon, name: 'Ticket Type A') }
    let(:child2) { create(:taxon, taxonomy: taxonomy, parent: parent_taxon, name: 'Ticket Type B') }
    let(:child3) { create(:taxon, taxonomy: taxonomy, parent: parent_taxon, name: 'Ticket Type C') }

    context 'when repositioning parent' do
      it 'updates the parent position correctly' do
        new_parent_taxon = create(:taxon, taxonomy: taxonomy, name: 'New Parent')
        child1.update(parent: new_parent_taxon)
        child2.update(parent: new_parent_taxon)
        child3.update(parent: new_parent_taxon)

        expect(new_parent_taxon.reload.children.order(:lft).pluck(:name)).to eq(['Ticket Type A', 'Ticket Type B', 'Ticket Type C'])
      end
    end

    context 'when repositioning children' do
      it 'orders children by lft attribute' do
        parent_taxon.children = [child3, child1, child2]
        parent_taxon.save!
        parent_taxon.reload

        expect(parent_taxon.reload.children.order(:lft).pluck(:name)).to eq(['Ticket Type C', 'Ticket Type A', 'Ticket Type B'])
      end
    end
  end

  describe 'factories' do
    it 'creates a valid cm_taxon_event_section' do
      section = create(:cm_taxon_event_section)
      expect(section).to be_valid
      expect(section.kind).to eq('event')
      expect(section.taxonomy.kind).to eq('event')
    end

    it 'creates a valid cm_taxon_event with sections and products' do
      event = create(:cm_taxon_event, sections_count: 2, products_count_per_section: 3)
      expect(event).to be_valid
      expect(event.children.count).to eq(2)

      event.children.each do |section|
        expect(section.products.count).to eq(3)
        expect(section.parent).to eq(event)
      end
    end
  end

  describe '#set_kind' do
    it 'sets the kind based on the taxonomy kind' do
      taxonomy = create(:taxonomy, kind: 'event')
      taxon = create(:cm_taxon_event, taxonomy: taxonomy)

      expect(taxon.kind).to eq('event')
    end
  end

  describe 'scopes' do
    describe '.visible_products' do
      let(:visible_classification) { create(:classification, visible: true) }
      let(:hidden_classification) { create(:classification, visible: false) }
      let(:taxon) { visible_classification.taxon }

      it 'includes products with visible classifications' do
        expect(taxon.visible_products).to include(visible_classification.product)
        expect(taxon.visible_products).not_to include(hidden_classification.product)
      end
    end
  end
end
