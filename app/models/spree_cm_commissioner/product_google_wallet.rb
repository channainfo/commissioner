module SpreeCmCommissioner
  class ProductGoogleWallet < Base
    belongs_to :product, class_name: 'Spree::Product'
    belongs_to :google_wallet, class_name: 'SpreeCmCommissioner::GoogleWallet'
  end
end
