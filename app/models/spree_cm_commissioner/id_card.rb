module SpreeCmCommissioner
  class IdCard < SpreeCmCommissioner::Base
    enum card_type: { :national_id_card => 0, :passport => 1, :student_id_card => 2 }

    belongs_to :guest, class_name: 'SpreeCmCommissioner::Guest'

    has_one :front_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::FrontImage'
    has_one :back_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::BackImage'

    self.whitelisted_ransackable_attributes = ['card_type']

    def allowed_checkout?
      if passport?
        front_image.present?
      elsif national_id_card? || student_id_card?
        front_image.present? && back_image.present?
      end
    end
  end
end
