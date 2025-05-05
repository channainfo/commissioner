module Spree
  module Admin
    class PostLinkController < Spree::Admin::BaseController
      before_action :find_product
      before_action :find_or_initialize_post_link, only: %i[index update]

      def index; end

      def update
        if @post_link.update(post_link_params)
          flash[:success] = 'Post link updated successfully!' # rubocop:disable Rails/I18nLocaleTexts
          redirect_to admin_product_post_link_url(@product)
        else
          flash[:error] = @post_link.errors.full_messages.join(', ')
          render :index
        end
      end

      private

      def find_product
        @product = Spree::Product.find(params[:product_id])
      end

      def find_or_initialize_post_link
        @post_link = @product.post_link || @product.build_post_link
      end

      def post_link_params
        params.require(:cm_post_link).permit(:title, :description, :url)
      end
    end
  end
end
