class AddPermissionsToRoles < ActiveRecord::Migration
  def change
    %w{
      manage_grant
      manage_editor
      manage_role
      manage_user
      manage_log}.each do |column|
      add_column :manage_roles, column, :integer, default: 0
    end
  end
end
