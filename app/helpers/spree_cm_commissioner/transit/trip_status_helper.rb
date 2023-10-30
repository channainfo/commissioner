module SpreeCmCommissioner
  module Transit
    module TripStatusHelper
      def public_status_btn(resource)
        label = resource.status ? 'Unpublish' : 'Public'
        btn_active_class = resource.status ? 'btn-warning' : 'btn-primary'
        button_to(
          label,
          public_status_transit_route_trip_url(id: resource.id),
          form: { data: { confirm: 'Are you sure?' }, class: "btn btn-sm btn-active btn-status #{btn_active_class}" },
          method: :patch
        )
      end
    end
  end
end