module SpreeCmCommissioner
  class PinCodeGenerator
    include Interactor::Organizer

    organize SpreeCmCommissioner::PinCodeCreator, SpreeCmCommissioner::PinCodeSender
  end
end
