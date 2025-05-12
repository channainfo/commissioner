class CmSeatSection < ApplicationRecord
  belongs_to :seat_layout, class_name: 'CmSeatLayout', foreign_key: 'layout_id'
  has_many :blocks, class_name: 'CmBlock', foreign_key: 'section_id', dependent: :destroy

  validates :section_name, presence: true
  validates :row, numericality: { only_integer: true, allow_nil: true }
  validates :column, :seats, :grids, numericality: { only_integer: true, allow_nil: true }

  scope :active, -> { where(active: true) } if column_names.include?('active')

  def total_seats
    seats || 0
  end
end
