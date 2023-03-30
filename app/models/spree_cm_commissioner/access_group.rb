module SpreeCmCommissioner
  class AccessGroup < ActiveRecord::Base
    acts_as_paranoid

    serialize :access, HashWithIndifferentAccess

    belongs_to :operator

    has_many :access_group_routes
    has_many :routes, through: :access_group_routes
    has_many :users

    accepts_nested_attributes_for :access_group_routes, allow_destroy: true

    validates :name, presence: true

    def toggle_activeness
      self.active = !self.active?
      self.save
    end
  end
end