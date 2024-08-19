require 'spec_helper'

RSpec.describe Spree::Product, type: :model do
  it { is_expected.to have_many(:product_places).class_name('SpreeCmCommissioner::ProductPlace').dependent(:destroy) }
  it { is_expected.to have_many(:places).through(:product_places) }
end