class AddFollowingEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :following_email, :integer
  end
end
