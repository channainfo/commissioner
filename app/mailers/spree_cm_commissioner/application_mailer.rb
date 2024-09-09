module SpreeCmCommissioner
  class ApplicationMailer < ActionMailer::Base
    default from: ENV.fetch('NO_REPLY_EMAIL', nil)
    layout 'mailer'
    # include Roadie::Rails::Mailer
  end
end
