module SpreeCmCommissioner
  class CheckinRecord < SpreeCmCommissioner::Base
    has_secure_token :token, length: 32

    enum verification_state: { submitted: 0, reviewed: 1, verified: 2, rejected: 3 }
    enum checkin_type: { pre_check_in: 0, walk_in: 1 }
    enum entry_type: { normal: 0, VIP: 1 }
    enum checkin_method: { manual: 0, scan: 1, sensor: 2, nfc: 3 }

    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :line_item, class_name: 'Spree::LineItem'
    belongs_to :guest, class_name: 'SpreeCmCommissioner::Guest'
    belongs_to :checkin_by, class_name: 'Spree::User'

    validates :guest_id, uniqueness: true
  end
end
