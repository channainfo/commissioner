module Spree
  module Admin
    class TenantVendorsController < Spree::Admin::ResourceController
      before_action :load_tenant

      def index
        @vendors = @tenant.vendors.includes(:tenant)
        @available_vendors = model_class.where(tenant_id: nil)
      end

      def create
        @vendor = model_class.find(params[:vendor_id])
        @vendor.tenant_id = @tenant.id
        if @vendor.save
          flash[:success] = flash_message_for(@vendor, :successfully_created)
        else
          flash[:error] = @vendor.errors.full_messages.to_sentence
        end
        redirect_to admin_tenant_vendors_path(@tenant)
      end

      def destroy
        @vendor = model_class.find(params[:id])
        @vendor.tenant_id = nil
        if @vendor.save
          flash[:success] = flash_message_for(@vendor, :successfully_removed)
        else
          flash[:error] = @vendor.errors.full_messages.to_sentence
        end

        respond_to do |format|
          format.html { redirect_to admin_tenant_vendors_path(@tenant) }
          format.js { render js: 'window.location.reload(true);' }
        end
      end

      private

      def load_tenant
        @tenant ||= SpreeCmCommissioner::Tenant.friendly.find(params[:tenant_id])
      end

      def model_class
        Spree::Vendor
      end
    end
  end
end
