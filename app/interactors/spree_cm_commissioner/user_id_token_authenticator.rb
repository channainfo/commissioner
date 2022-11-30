module SpreeCmCommissioner
  class UserIdTokenAuthenticator
    include Interactor::Organizer

    organize SpreeCmCommissioner::UserIdTokenChecker
  end
end
