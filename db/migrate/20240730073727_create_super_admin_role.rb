class CreateSuperAdminRole < ActiveRecord::Migration[7.0]
  def change
    super_admin = Spree::Role.find_or_create_by(name: 'super_admin')

    user = Spree::User.find_by(email: 'a@vtenh.com')
    if user
      user.spree_roles << super_admin unless user.spree_roles.include?(super_admin)
    end
  end
end
