module SpreeCmCommissioner
  class Guest < SpreeCmCommissioner::Base
    enum gender: { :other => 0, :male => 1, :female => 2 }
    enum occupation: { :other_field => 0, :student => 1, :professional => 2, :employee => 3, :entrepreneur => 4 }

    has_one :id_card, class_name: 'SpreeCmCommissioner::IdCard', dependent: :destroy
  end
end
