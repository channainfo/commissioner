module SpreeCmCommissioner
  class HomepageSection < Base
    acts_as_list column: :position

    attribute :title
    attribute :description
    attribute :active
    attribute :position

    has_many :homepage_section_relatables, dependent: :destroy
  end
end
