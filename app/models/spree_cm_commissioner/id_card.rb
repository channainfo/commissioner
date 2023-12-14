module SpreeCmCommissioner
  class IdCard < SpreeCmCommissioner::Base
    enum card_type: { :identity_card => 0, :passport => 1 }

    has_one :front_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::FrontImage'
    has_one :back_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::BackImage'
  end
end
