module SpreeCmCommissioner
  class CheckIn < SpreeCmCommissioner::Base
    has_secure_token :token, length: 32

    enum verification_state: { submitted: 0, reviewed: 1, verified: 2, rejected: 3 }
    enum check_in_type: { pre_check_in: 0, walk_in: 1 }
    enum entry_type: { normal: 0, VIP: 1 }
    enum check_in_method: { manual: 0, scan: 1, sensor: 2, nfc: 3 }

    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :line_item, class_name: 'Spree::LineItem'
    belongs_to :guest, class_name: 'SpreeCmCommissioner::Guest'
    belongs_to :check_in_by, class_name: 'Spree::User'

    validates :guest_id, uniqueness: true
  end
end
