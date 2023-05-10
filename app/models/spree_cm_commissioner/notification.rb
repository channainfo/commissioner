module SpreeCmCommissioner
  class Notification < SpreeCmCommissioner::Base
    include Noticed::Model

    belongs_to :recipient, polymorphic: true
    belongs_to :notificable, polymorphic: true

    validates :recipient_id, uniqueness: { scope: %i[notificable_id notificable_type] }
  end
end
