module SpreeCmCommissioner
  class WaitingRoomSession < Base
    validates :jwt_token, presence: true
    validates :expired_at, presence: true
    validates :remote_ip, presence: true

    scope :active, -> { SpreeCmCommissioner::WaitingRoomSession.where('expired_at > ?', Time.current) }

    def expired?
      expired_at < Time.current
    end
  end
end
