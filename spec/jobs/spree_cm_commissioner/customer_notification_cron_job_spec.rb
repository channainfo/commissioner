require 'spec_helper'

RSpec.describe SpreeCmCommissioner::CustomerNotificationCronJob, type: :job do
  include ActiveJob::TestHelper
  it 'perform a call to CustomerNotificationCronExecutor' do
    expect(SpreeCmCommissioner::CustomerNotificationCronExecutor).to receive(:call)
    cron = SpreeCmCommissioner::CustomerNotificationCronJob.new
    cron.perform
  end
end
