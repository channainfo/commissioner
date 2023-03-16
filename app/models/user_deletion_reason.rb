class UserDeletionReason < ApplicationRecord
  def title_tran
    I18n.t(title)
  end

  def reason_desc_tran
    return unless reason_desc?

    I18n.t(reason_desc)
  end

  def self.generate_default_deletions
    default_deletions.each do |deletion_reason|
      record = UserDeletionReason.where(title: deletion_reason[:title]).first_or_initialize
      record.assign_attributes(deletion_reason)
      record.save
    end
  end

  def self.default_deletions
    [
      {
        title: 'account_deletion.title.have_another_account',
        skip_reason: true,
        reason_desc: nil
      },
      {
        title: 'account_deletion.title.too_many_notifications',
        skip_reason: true,
        reason_desc: nil
      },
      {
        title: 'account_deletion.title.sth_broken',
        skip_reason: false,
        reason_desc: 'account_deletion.reason_description.sth_broken'
      },
      {
        title: 'account_deletion.title.other',
        skip_reason: false,
        reason_desc: 'account_deletion.reason_description.other'
      }
    ]
  end
end
