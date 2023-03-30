module SpreeCmCommissioner
  class RolePermission < SpreeCmCommissioner::Base
    belongs_to :role, class_name: 'Spree::Role'
    belongs_to :permission, class_name: 'SpreeCmCommissioner::Permission'

    accepts_nested_attributes_for :permission

    delegate :slug, :entry, :action, to: :permission

    validates :permission_id, uniqueness: { scope: :role_id }
  end
end
