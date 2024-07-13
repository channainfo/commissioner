# TODO: research why searchkick is not compatible with pagination
# Searchkick::Relation.class_eval do
#   alias_method :per, :per_page unless respond_to?(:per)
# end

Searchkick.client = OpenSearch::Client.new(
  url: ENV['SEARCH_SERVER_URL'] || 'http://localhost:9200',
  transport_options: {
    request: { timeout: 600, open_timeout: 600 }
  }
)
