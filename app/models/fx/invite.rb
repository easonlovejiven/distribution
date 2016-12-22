class Fx::Invite < ActiveRecord::Base
  self.table_name = "fx_invites"
  #邀请表
  belongs_to :user
  belongs_to :used_byer,foreign_key: "used_by",class_name: "Fx::User"

end
