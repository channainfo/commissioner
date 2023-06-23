require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerNotificationCron, type: :job do
  include ActiveJob::TestHelper
  it 'perform a call to CustomerNotificationCronExecutor' do
    expect(SpreeCmCommissioner::CustomerNotificationCronExecutor).to receive(:call)
    cron = SpreeCmCommissioner::CustomerNotificationCron.new
    cron.perform
  end
end