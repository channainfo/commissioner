module SpreeCmCommissioner
  module WishedItemDecorator
    def self.prepended(base)
      base.after_create :clear_user_wished_item_ids
      base.after_destroy :clear_user_wished_item_ids
    end

    def clear_user_wished_item_ids
      user_id = wishlist.user_id
      user_wish_item = Spree::WishedItem.new(user_id)
      user_wish_item.clear_cache
    end
  end
end

Spree::WishedItem.prepend(SpreeCmCommissioner::WishedItemDecorator)
