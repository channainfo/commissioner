module SpreeCmCommissioner
  class HomepageSection < Base
    include SpreeCmCommissioner::HomepageSectionBitwise

    acts_as_list column: :position

    multi_tenant :tenant, class_name: 'SpreeCmCommissioner::Tenant'

    attribute :segment, :integer, default: 0

    has_many :homepage_section_relatables, -> { active }, inverse_of: :homepage_section, dependent: :destroy

    scope :active, lambda {
      joins(:homepage_section_relatables)
        .where(active: true)
        .group('cm_homepage_sections.id')
        .having('COUNT(cm_homepage_section_relatables.id) > 0')
        .order(:position)
    }

    scope :filter_by_segment, -> (segment) { where('segment & ? > 0', BIT_SEGMENT[segment.to_sym]) }

    def tenant_id=(new_tenant_id)
      self[:tenant_id] = new_tenant_id
    end
  end
end
