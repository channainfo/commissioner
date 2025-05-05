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
        assign_option_types
        assign_option_values
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

      return if @parent_taxon.save

      context.fail!(message: @parent_taxon.errors.full_messages.join(', '))
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

    def assign_options(model_class, param_key, foreign_key)
      return unless params[param_key]

      params[param_key].each do |id|
        record = model_class.new(
          taxon_id: @parent_taxon.id,
          foreign_key => id
        )

        context.fail!(message: record.errors.full_messages.join(', ')) unless record.save
      end
    end

    def assign_option_types
      assign_options(SpreeCmCommissioner::TaxonOptionType, :option_type_id, :option_type_id)
    end

    def assign_option_values
      assign_options(SpreeCmCommissioner::TaxonOptionValue, :option_value_id, :option_value_id)
    end
  end
end
