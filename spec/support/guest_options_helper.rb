module GuestOptionsHelper
  def options_klass = SpreeCmCommissioner::Pricings::Options
  def guest_options_klass = SpreeCmCommissioner::Pricings::GuestOptions
  def date_options_klass = SpreeCmCommissioner::Pricings::DateOptions

  def kids(number)
    kids_option_type = create(:cm_option_type, :kids)
    create(:option_value, name: "#{number}-kids", presentation: "#{number}", option_type: kids_option_type)
  end

  def adults(number)
    adults_option_type = create(:cm_option_type, :adults)
    create(:option_value, name: "#{number}-adults", presentation: "#{number}", option_type: adults_option_type)
  end

  def allowed_extra_kids(number)
    allowed_extra_kids_option_type = create(:cm_option_type, :allowed_extra_kids)
    create(:option_value, name: "allowed-#{number}-kids", presentation: "#{number}", option_type: allowed_extra_kids_option_type)
  end

  def allowed_extra_adults(number)
    allowed_extra_adults_option_type = create(:cm_option_type, :allowed_extra_adults)
    create(:option_value, name: "allowed-#{number}-adults", presentation: "#{number}", option_type: allowed_extra_adults_option_type)
  end
end
