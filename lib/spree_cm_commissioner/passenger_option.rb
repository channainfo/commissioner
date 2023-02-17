module SpreeCmCommissioner
  class PassengerOption
    attr_reader :adult, :children, :room_qty

    def initialize(adult:, children:, room_qty:)
      @adult = adult
      @room_qty = room_qty
      @children = children
    end
  end
end
