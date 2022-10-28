# head
Deface::Override.new(
  name: "shared-map-map-head",
  virtual_path: "spree/layouts/admin",
  insert_bottom: "[data-hook='admin_inside_head']",
  partial: "shared/map/map_head"
)