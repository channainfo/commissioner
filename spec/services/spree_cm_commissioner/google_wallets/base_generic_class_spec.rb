require 'spec_helper'

RSpec.describe SpreeCmCommissioner::GoogleWallets::BaseGenericClass do
  let(:google_wallet_class) { instance_double('SpreeCmCommissioner::GoogleWallets::BaseGenericClass') }
  subject { described_class.new(google_wallet_class) }

  describe '#build_request_body' do
    it 'raises NotImplementedError' do
      expect { subject.build_request_body }.to raise_error NotImplementedError
    end
  end
end
