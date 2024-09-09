require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserTaxon, type: :model do
  describe 'associations' do
    it { should belong_to(:user).class_name(Spree.user_class.to_s) }
    it { should belong_to(:taxon).class_name('Spree::Taxon') }
  end
end
