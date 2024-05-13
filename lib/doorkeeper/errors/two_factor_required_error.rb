module Doorkeeper
  module Errors
    class TwoFactorRequiredError < Doorkeeper::Errors::DoorkeeperError
      def type
        :two_factor_required
      end
    end
  end
end
