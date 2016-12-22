class Fx::Setting < ActiveRecord::Base
  self.table_name = "fx_settings"
  serialize :value
  # serialize :apply
  # serialize :poster
end
