module SpreeCmCommissioner
  module Transit
    module ServiceCalendarHelper
      def toggle_status_btn(resource)
        label = resource.active ? 'Active' : 'Disabled'
        btn_active_class = resource.active ? 'btn-primary' : 'btn-warning'
        button_to(
          label,
          update_status_transit_service_calendar_url(resource.id),
          form: { data: { confirm: 'Are you sure?' }, class: "btn btn-sm btn-active btn-status #{btn_active_class}" },
          method: :patch
        )
      end
    end
  end
end
 