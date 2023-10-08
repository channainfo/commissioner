require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RecaptchaTokenValidator do
  let(:project_id) { 'central-market-internal' }
  let(:site_key) { 'site-key' }
  let(:token) { 'valid_token' }
  let(:action) { 'register' }

  describe '.call' do
    it 'succeeds when response JSON is valid, score qualifies, and action matches' do
      correct_action = 'register'

      allow_any_instance_of(described_class)
        .to receive(:create_assessment)
        .and_return(double('response', token_properties: double('token_properties', valid: true, action: correct_action), risk_analysis: double('risk_analysis', score: 0.8)))

      context = described_class.call(project_id: project_id, site_key: site_key, token: token, action: action)
      expect(context.success?).to be true
    end

    it 'fails when action does not match' do
      incorrect_action = 'incorrect_action'

      allow_any_instance_of(described_class)
        .to receive(:create_assessment)
        .and_return(double('response', token_properties: double('token_properties', valid: true, action: incorrect_action), risk_analysis: double('risk_analysis', score: 0.6)))

      context = described_class.call(project_id: project_id, site_key: site_key, token: token, action: action)
      expect(context.success?).to be false
      expect(context.message).to eq(I18n.t('recaptcha.action_not_matched'))
    end
  end
end