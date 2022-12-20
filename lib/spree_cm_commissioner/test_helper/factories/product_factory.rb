FactoryBot.define do
  factory :cm_product, class: Spree::Product do    
    factory :cm_product_with_master_option_types do

      initialize_with do
        stock_locations = [ create(:stock_location) ]
        product = create(:product, vendor: create(:active_vendor, stock_locations: stock_locations))
        product
      end

      before(:create) do |product|
        master_option_type = Spree::OptionType.create(is_master: true, presentation: "Bathroom & Toiletries", name: "bathroom-toiletries")
        master_option_values = [
          Spree::OptionValue.create(option_type: master_option_type, presentation: "Accessible toilet", name: "accessible-toilet"),
          Spree::OptionValue.create(option_type: master_option_type, presentation: "Adapted bath", name: "adapted-bath")
        ]

        normal_option_type = Spree::OptionType.create(is_master: false, presentation: "Capacity", name: "capacity")
        normal_option_values = [
          Spree::OptionValue.create(option_type: normal_option_type, presentation: "1 people", name: "1-people")
        ]

        variant = build(:master_variant, product: product, option_values: master_option_values)
        product.option_types = product.option_types + [ master_option_type, normal_option_type ]
        product.master = variant
        product.save!

        product.reload
      end
    end
  end
end
