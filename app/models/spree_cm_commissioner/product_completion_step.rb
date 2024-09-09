module SpreeCmCommissioner
  class ProductCompletionStep < Base
    acts_as_list column: :position

    belongs_to :product, class_name: '::Spree::Product', optional: false

    def action_url_for(_line_item)
      nil
    end

    def completed?(_line_item)
      raise 'completed? should be implemented in a sub-class of ProductCompletionStep'
    end

    def construct_hash(line_item:)
      {
        title: title,
        type: type&.underscore,
        position: position,
        description: description,
        action_label: action_label,
        action_url: action_url_for(line_item),
        completed: completed?(line_item)
      }
    end
  end
end
