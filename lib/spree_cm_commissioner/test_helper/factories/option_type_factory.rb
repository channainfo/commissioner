FactoryBot.define do
  factory :cm_option_type, class: Spree::OptionType do
    sequence(:name) { |n| "foo-size-#{n}" }
    presentation    { 'Size' }

    trait :location do
      attr_type { :state_selection }
      name { 'location' }
      presentation { 'location' }
    end

    trait :start_date do
      attr_type { :date }
      name { 'start-date' }
      presentation { 'start-date' }
    end

    trait :end_date do
      attr_type { :date }
      name { 'end-date' }
      presentation { 'end-date' }
    end

    trait :start_time do
      attr_type { :time }
      name { 'start-time' }
      presentation { 'start-time' }
    end

    trait :end_time do
      attr_type { :time }
      name { 'end-time' }
      presentation { 'end-time' }
    end

    trait :reminder_in_hours do
      attr_type { :integer }
      name { 'reminder-in-hours' }
      presentation { 'reminder-in-hours' }
    end

    trait :duration_in_hours do
      attr_type { :integer }
      name { 'duration-in-hours' }
      presentation { 'duration-in-hours' }
    end

    trait :duration_in_minutes do
      attr_type { :integer }
      name { 'duration-in-minutes' }
      presentation { 'duration-in-minutes' }
    end

    trait :duration_in_seconds do
      attr_type { :integer }
      name { 'duration-in-seconds' }
      presentation { 'duration-in-seconds' }
    end

    trait :payment_option do
      attr_type { :payment_option }
      name { 'payment-option' }
      presentation { 'payment-option' }
    end

    trait :delivery_option do
      attr_type { :delivery_option }
      name { 'delivery-option' }
      presentation { 'delivery-option' }
    end

    trait :max_quantity_per_order do
      attr_type { :integer }
      name { 'max-quantity-per-order' }
      presentation { 'max-quantity-per-order' }
    end

    trait :due_date do
      attr_type { :integer }
      name { 'due-date' }
      presentation { 'due-date' }
    end

    trait :month do
      attr_type { :integer }
      name { 'month' }
      presentation { 'month' }
    end

    trait :number_of_adults do
      attr_type { :integer }
      name { 'number-of-adults' }
      presentation { 'number-of-adults' }
    end

    trait :number_of_kids do
      attr_type { :integer }
      name { 'number-of-kids' }
      presentation { 'number-of-kids' }
    end

    trait :kids_age_max do
      attr_type { :integer }
      name { 'kids-age-max' }
      presentation { 'kids-age-max' }
    end

    trait :allowed_extra_adults do
      attr_type { :integer }
      name { 'allowed-extra-adults' }
      presentation { 'allowed-extra-adults' }
    end

    trait :allowed_extra_kids do
      attr_type { :integer }
      name { 'allowed-extra-kids' }
      presentation { 'allowed-extra-kids' }
    end

    trait :bib_prefix do
      attr_type { :string }
      name { 'bib-prefix' }
      presentation { 'bib-prefix' }
    end

    trait :bib_zerofill do
      attr_type { :integer }
      name { 'bib-zerofill' }
      presentation { 'bib-zerofill' }
    end

    trait :bib_display_prefix do
      attr_type { :boolean }
      name { 'bib-display-prefix' }
      presentation { 'Should display bib prefix?' }
    end

    trait :bib_pre_generation_on_create do
      attr_type { :boolean }
      name { 'bib-pre-generation-on-create' }
      presentation { 'Should pre generate bib on create' }
    end

    trait :seat_number_positions do
      attr_type { :array }
      name { 'seat-number-positions' }
      presentation { 'seat-number-positions' }
    end

    initialize_with { Spree::OptionType.where(name: name).first_or_initialize }
  end
end
