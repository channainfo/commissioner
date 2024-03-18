
class API::V2::AffiliateBannerSerializer < API::V2::BaseSerializer
  attributes %i[
    name url banner_clicks_count banner_text description
    image status start_date end_date
  ]

  def image
    {
      thumb: object.banner.thumb.url,
      medium: object.banner.medium.url,
      standard: object.banner.standard.url
    }
  end
end