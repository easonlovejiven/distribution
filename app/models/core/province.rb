class Core::Province < ActiveRecord::Base
  establish_connection(Rails.configuration.database_configuration["core"][Rails.env])
end
