module SpreeCmCommissioner
  class CreateEvent
    include Interactor
    delegate :params, :current_vendor, to: :context

    def call
      ActiveRecord::Base.transaction do
        build_parent_taxon
        assign_vendor
        assign_prototype
        create_child_taxon
        build_home_banner
      end
    end

    private

    def build_parent_taxon
      @parent_taxon = Spree::Taxon.new(
        name: context.params[:name],
        description: context.params[:description],
        from_date: context.params[:from_date],
        to_date: context.params[:to_date],
        parent_id: context.params[:parent_id],
        taxonomy_id: context.params[:taxonomy_id]
      )

      if @parent_taxon.save
        context.slug = @parent_taxon.event_slug
      else
        context.fail!(message: @parent_taxon.errors.full_messages.join(', '))
      end
    end

    def assign_vendor
      @parent_taxon.vendors << context.current_vendor
    end

    def assign_prototype
      prototype = Spree::Prototype.find_by(slug: context.params[:prototype_id])
      @parent_taxon.prototypes << prototype if prototype.present?
    end

    def create_child_taxon
      child_taxon = Spree::Taxon.new(
        name: 'Ticket Type',
        from_date: @parent_taxon.from_date,
        to_date: @parent_taxon.to_date,
        parent_id: @parent_taxon.id,
        taxonomy_id: context.params[:taxonomy_id]
      )

      return if child_taxon.save

      context.fail!(message: child_taxon.errors.full_messages.join(', '))
    end

    def build_home_banner
      return if context.params[:home_banner].nil?

      banner = SpreeCmCommissioner::TaxonHomeBanner.create(
        viewable: @parent_taxon,
        attachment: context.params[:home_banner]
      )

      context.fail!(message: 'Home banner upload failed') unless banner.persisted?
    end
  end
end
