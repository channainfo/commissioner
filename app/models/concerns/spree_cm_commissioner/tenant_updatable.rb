module SpreeCmCommissioner
  module TenantUpdatable
    extend ActiveSupport::Concern

    included do
      # Override tenant immutability to allow clearing tenant_id
      def tenant_id=(new_tenant_id)
        self[:tenant_id] = new_tenant_id
      end
    end
  end
end
