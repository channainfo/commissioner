class CmBlock < ApplicationRecord
  belongs_to :section, class_name: 'CmSeatSection', foreign_key: 'section_id'
  has_many :variant_blocks, class_name: 'CmVariantBlock', foreign_key: 'block_id'
end
