module Personalization
  class SearchKeywordResult
    attr_accessor :id, :aggregators, :suggestions, :products, :taxon, :sjid, :meta, :recommendation_id

    include ActiveModel::Serialization
    # include AssignableFieldObject
  end
end
