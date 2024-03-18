module Spree
  module Transit
    class PlacesController < Spree::Transit::BaseController
      before_action :load_place_taxonomy
      helper 'spree/transit/sortable_tree'

      def load_place_taxonomy
        @place_taxonomy = Spree::Taxonomy.place
      end

      before_action :set_permalink_part, only: [:edit]
      respond_to :html, :js
      helper 'spree/transit/sortable_tree'
      before_action :set_data_type, only: %i[update create]

      def index; end

      def new
        @taxon = Spree::Taxon.new
        @taxon.taxonomy = @place_taxonomy
      end

      def update # rubocop:disable Metrics/AbcSize
        successful = @taxon.transaction do
          parent_id = params[:taxon][:parent_id]
          set_position
          assign_parent(parent_id)

          @taxon.save!

          # regenerate permalink
          regenerate_permalink if parent_id

          set_permalink_params

          # check if we need to rename child taxons if parent name or permalink changes
          @update_children = true if params[:taxon][:name] != @taxon.name || params[:taxon][:permalink] != @taxon.permalink

          @taxon.create_icon(attachment: taxon_params[:icon]) if taxon_params[:icon]
          @taxon.update(taxon_params.except(:icon))
        end
        if successful
          flash[:success] = flash_message_for(@taxon, :successfully_updated)

          # rename child taxons
          rename_child_taxons if @update_children

          respond_with(@taxon) do |format|
            format.html { redirect_to spree.edit_transit_place_url(params[:id]) }
            format.json { render json: @taxon.to_json }
          end
        else
          respond_with(@taxon) do |format|
            format.html { render :edit, status: :unprocessable_entity }
            format.json { render json: @taxon.errors.full_messages.to_sentence, status: :unprocessable_entity }
          end
        end
      end

      def location_after_save
        spree.transit_places_url
      end

      def set_permalink_part
        @permalink_part = @object.permalink.split('/').last
        @parent_permalink = @object.permalink.split('/')[0...-1].join('/')
        @parent_permalink += '/' if @parent_permalink.present?
      end

      def set_permalink_params
        set_permalink_part

        return unless params.key? 'permalink_part'

        params[:taxon][:permalink] = @parent_permalink + params[:permalink_part]
      end

      def taxon_params
        params.require(:taxon).permit(:stop, :branch, :location, permitted_taxon_attributes)
      end

      def set_position
        new_position = params[:taxon][:position]
        @taxon.child_index = new_position.to_i if new_position
      end

      # If this method is applied to the model, it will set stop, location, and
      # taxon attributes to 0 when a drag-and-drop action changes the position.
      def set_data_type
        if params[:taxon][:stop].to_i.zero? && params[:taxon][:branch].to_i.zero?
          # If not checked, it will set the location instead.
          params[:taxon][:location] = 1
          @taxon[:data_type] = (params[:taxon][:location].to_i * (2**2))
        end

        result = (params[:taxon][:stop].to_i * (2**0)) + (params[:taxon][:branch].to_i * (2**1)) + (params[:taxon][:location].to_i * (2**2))
        @taxon[:data_type] = result
      end

      def assign_parent(parent_id)
        @taxon.parent = current_store.taxons.find(parent_id) if parent_id
      end

      def parent_data
        if action_name == 'index'
          nil
        else
          super
        end
      end

      def rename_child_taxons
        @taxon.descendants.each do |taxon|
          reload_taxon_and_set_permalink(taxon)
        end
      end

      def regenerate_permalink
        reload_taxon_and_set_permalink(@taxon)
        @update_children = true
      end

      def reload_taxon_and_set_permalink(taxon)
        taxon.reload
        taxon.set_permalink
        taxon.save!
      end

      def collection_url
        spree.polymorphic_url([:transit, place.to_sym], options)
      end

      def edit_transit_taxon_path(taxon)
        spree.edit_transit_taxonomy_taxon_path(taxon.taxonomy, taxon.id)
      end

      def scope
        current_store.taxonomies
      end

      def model_class
        Spree::Taxon
      end

      def object_name
        'taxon'
      end
    end
  end
end
