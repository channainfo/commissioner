module SpreeCmCommissioner
  module Admin
    module ServiceCalendarsHelper
      def toggle_status_btn(resource)
        label = resource.active ? 'Active' : 'Disabled'
        btn_active_class = resource.active ? 'btn-primary' : 'btn-warning'

        button_to(
          label,
          update_status_admin_vendor_vendor_service_calendar_url(resource.calendarable, resource),
          form: { data: { confirm: 'Are you sure?' }, class: "btn btn-sm btn-active #{btn_active_class}" },
          method: :patch
        )
      end
    end
  end
end
