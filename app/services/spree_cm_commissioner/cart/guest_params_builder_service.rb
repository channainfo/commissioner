module SpreeCmCommissioner
  module Cart
    class GuestParamsBuilderService
      def initialize(params)
        @params = params
      end

      def build
        if @params[:template_guest_id].present?
          merge_with_template_guest
        else
          permitted_guest_params
        end
      end

      private

      def merge_with_template_guest
        template_guest = SpreeCmCommissioner::TemplateGuest.find(@params[:template_guest_id])
        permitted_guest_params.merge(template_guest.attributes.except('id', 'created_at', 'updated_at', 'is_default', 'deleted_at'))
      end

      def permitted_guest_params
        @params.permit(
          :first_name,
          :last_name,
          :dob,
          :gender,
          :occupation_id,
          :nationality_id,
          :other_occupation,
          :social_contact,
          :social_contact_platform,
          :age,
          :emergency_contact,
          :phone_number,
          :address,
          :other_organization,
          :expectation,
          :upload_later,
          :template_guest_id
        )
      end
    end
  end
end
