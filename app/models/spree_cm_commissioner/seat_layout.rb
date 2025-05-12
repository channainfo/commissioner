class SpreeCmCommissioner::SeatLayout < Spree::Base
  belongs_to :layoutable, polymorphic: true, optional: true
  has_many :seat_sections, class_name: 'CmSeatSection', foreign_key: 'layout_id', dependent: :destroy


  enum layout_type: {
    bus: 0,
    van: 1,
    taxi: 2,
    ferry: 3,
  }

  enum status: {
    active: 0,
    inactive: 1,
    archived: 2,
  }

  validates :layout_name, presence: true
  validates :layout_type, presence: true
  validates :total_seats, presence: true, numericality: { greater_than: 0 }
  validates :sections, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :layoutable_type, presence: true, if: :layoutable_id?
  validates :layoutable_id, presence: true, if: :layoutable_type?
end
