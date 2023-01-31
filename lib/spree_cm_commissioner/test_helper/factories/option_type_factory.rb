FactoryBot.define do
  factory :cm_option_type, class: Spree::OptionType do
    name { FFaker::Name.unique.name }
    presentation { FFaker::Name.unique.name }
    attr_type { :string }

    transient do
      with_option_values { false }
    end

    after :build do |option_type, evaluator|
      option_type.option_values = [ 
        build(:cm_option_value, option_type: option_type),
        build(:cm_option_value, option_type: option_type),
      ] if evaluator.with_option_values
    end

    factory :variant_kind_option_type do
      kind { :variant }
    end

    factory :product_kind_option_type do
      kind { :product }
    end

    factory :vendor_kind_option_type do
      kind { :vendor }
    end
  end
end
