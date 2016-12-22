class Core::TaskUser < ActiveRecord::Base
  establish_connection(Rails.configuration.database_configuration["core"][Rails.env])
  self.table_name = "task_users"
  
  scope :recent, -> { order('created_at DESC') }

  

end
