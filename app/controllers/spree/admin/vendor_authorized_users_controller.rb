module Spree
  module Admin
    class VendorAuthorizedUsersController < Spree::Admin::ResourceController
      before_action :load_vendor

      def load_vendor
        @vendor ||= Spree::Vendor.by_vendor_id!(params[:vendor_id])
      end

      def collection
        load_vendor

        @users = @vendor.users
      end

      def update_telegram_chat
        context = ::SpreeCmCommissioner::TelegramChatsFinder.call(
          telegram_chat_name: params['vendor']['preferred_telegram_chat_name'],
          telegram_chat_type: params['vendor']['preferred_telegram_chat_type']
        )

        if context.chats.present? && context.chats.is_a?(Hash)
          vendor_attributes = {
            preferred_telegram_chat_name: params['vendor']['preferred_telegram_chat_name'],
            preferred_telegram_chat_type: params['vendor']['preferred_telegram_chat_type'],
            preferred_telegram_chat_id: context.chats[:id]
          }

          flash[:error] = @vendor.errors.full_messages.to_sentence unless @vendor.update(vendor_attributes)
        else
          flash[:error] = I18n.t('vendor.validation.could_not_find_telegram_chat')
        end

        redirect_to collection_url(@vendor)
      end

      # @overrided
      def model_class
        Spree::User
      end

      # @overrided
      def object_name
        'user'
      end

      # @overrided
      def collection_url(options = {})
        admin_vendor_vendor_authorized_users_url(options)
      end
    end
  end
end
