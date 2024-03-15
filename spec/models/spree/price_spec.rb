require 'spec_helper'

RSpec.describe Spree::Price, type: :model do
  describe 'associations' do
    it { should belong_to(:priceable).required(true) }
    it { should belong_to(:variant).required(false) }
  end
end
