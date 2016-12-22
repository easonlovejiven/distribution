class Fx::Upgrade < ActiveRecord::Base
  self.table_name = "fx_upgrades"
  belongs_to :level
end
