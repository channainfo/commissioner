module Spree
  module Billing
    class RolesController < Spree::Billing::BaseController
      before_action :load_role, if: -> { member_action? }
      before_action :load_role_permissions, if: -> { member_action? }
      before_action :construct_role_permissions, only: %i[create update]

      def collection
        return @collection if defined?(@collection)

        @search = Spree::Role.ransack(params[:q])
        @collection = @search.result.page(params[:page]).per(15)
      end

      def model_class
        Spree::Role
      end

      def object_name
        'role'
      end

      def collection_url(options = {})
        billing_roles_url(options)
      end

      def load_role
        @role = @object || Spree::Role.new
      end

      def load_role_permissions
        @role_permissions = Spree::Core::Engine.routes.routes.filter_map do |route|
          if route.defaults.key?(:controller) && route.defaults.key?(:action)
            entry = route.defaults.fetch(:controller)
            action = route.defaults.fetch(:action)

            if include_permission_hashes[entry]&.include?(action)
              permission = SpreeCmCommissioner::Permission.where(
                entry: entry,
                action: action
              ).first_or_initialize

              if @role.persisted? && permission.persisted?
                SpreeCmCommissioner::RolePermission.where(
                  role: @role,
                  permission: permission
                ).first_or_initialize
              else
                SpreeCmCommissioner::RolePermission.new(
                  role: @role,
                  permission: permission
                )
              end
            end
          end
        end.uniq(&:slug)
      end

      def include_permission_hashes
        @include_permission_hashes ||= {
          'spree/billing/reports' => %w[index paid balance_due overdue failed_orders active_subscribers print_all_invoices],
          'spree/billing/orders' => %w[index create new edit show update destroy],
          'spree/billing/users' => %w[index create new edit show update destroy],
          'spree/billing/subscriptions' => %w[index create new edit show update destroy],
          'spree/billing/customers' => %w[index create new edit show update destroy apply_promotion delete_promotion],
          'spree/billing/roles' => %w[index create new edit show update destroy],
          'spree/billing/vendors' => %w[edit show update],
          'spree/billing/places' => %w[index create new edit show update destroy],
          'spree/billing/businesses' => %w[index create new edit show update destroy],
          'spree/billing/products' => %w[index create new edit show update destroy],
          'spree/billing/variants' => %w[index create new edit show update destroy],
          'spree/billing/option_types' => %w[index create new edit show update destroy],
          'spree/billing/adjustments' => %w[index create new edit show update destroy],
          'spree/billing/payments' => %w[index create new edit show update destroy],
          'spree/billing/invoice' => %w[index show print_invoice_date],
          'spree/billing/addresses' => %w[index create new edit show update destroy]
        }
      end

      def construct_role_permissions
        role_permissions_attributes = {}

        permitted_resource_params[:role_permissions_attributes].each do |id, role_permission_attributes|
          selected = role_permission_attributes[:selected] == 'true'
          persisted = role_permission_attributes.to_h.key?(:id)
          permission_persisted = role_permission_attributes[:permission_attributes].key?(:id)
          role_permission_attributes = role_permission_attributes.except(:selected)

          if permission_persisted
            role_permission_attributes[:permission_id] = role_permission_attributes[:permission_attributes][:id]
            role_permission_attributes.delete(:permission_attributes)
          end

          if selected
            role_permissions_attributes[id] = role_permission_attributes
          elsif persisted
            role_permission_attributes[:_destroy] = 1
            role_permissions_attributes[id] = role_permission_attributes
          end
        end

        permitted_resource_params[:role_permissions_attributes] = role_permissions_attributes
      end
    end
  end
end
