class Manage::Log < ActiveRecord::Base
  self.table_name = "manage_logs"
	CONTROLLERS = %w[

	]

	ACTIONS = %w[

	]
	# enum controller: CONTROLLERS.map { |controller| "_controller_#{controller}" }, action: ACTIONS.map { |action| "_action_#{action}" }
end
