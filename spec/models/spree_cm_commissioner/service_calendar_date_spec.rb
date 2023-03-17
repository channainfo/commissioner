require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ServiceCalendarDate, type: :model do
  it { should belong_to(:service_calendar) }
  it { should define_enum_for(:exception_type).with_values({:inclusion => 1, :exclusion => 2}) }
  it { should validate_presence_of(:date) }
end
