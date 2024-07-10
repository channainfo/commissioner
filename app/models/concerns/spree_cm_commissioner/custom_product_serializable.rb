module SpreeCmCommissioner
  module CustomProductSerializable
    def product_master_images(product, ignore_detailed_images=false)
      product.master.images.map do |image|
        data = {
          id: image.id,
          viewable_type: image.viewable_type,
          viewable_id: image.viewable_id,
          styles: [ image.image_style(:product) ],
        }

        # Improve unnecesary loading v1.2.0  and maintain backward compatibility
        data[:mobile_image_styles] = image.mobile_image_styles if ignore_detailed_images == false
        data
      end
    end

    def product_vendor(product)
      return {} if product.vendor.nil?

      {
        id: product.vendor.id,
        is_type_vmall: product.vendor.type_vmall?,
        vendor_type: product.vendor.vendor_type,
        slug: product.vendor.slug,
        name: product.vendor.name,
      }
    end
  end
end
