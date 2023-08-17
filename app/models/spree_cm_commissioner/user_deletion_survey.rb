module SpreeCmCommissioner
  class UserDeletionSurvey < SpreeCmCommissioner::Base
    belongs_to :user, class_name: 'Spree::User'
    belongs_to :user_deletion_reason
  end
end
