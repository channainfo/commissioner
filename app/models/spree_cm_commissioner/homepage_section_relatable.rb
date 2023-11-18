module SpreeCmCommissioner
  class HomepageSectionRelatable < Base
    acts_as_list column: :position

    belongs_to :homepage_section
    belongs_to :relatable, polymorphic: true
  end
end
