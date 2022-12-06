# TODO: research why searchkick doesn't comparitable with pagination
Searchkick::Relation.class_eval do
  alias_method :per, :per_page unless self.respond_to?(:per)
end