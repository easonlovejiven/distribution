class Manage::Notification < ActiveRecord::Base

    belongs_to :sender, foreign_key: 'user_id', class_name: 'Manage::User'
    belongs_to :receiver, foreign_key: 'receiver_id', class_name: 'Manage::User'

    def self.deliver(options={})
        notification = self.new
        notification.user_id = options[:user_id] || (options[:user] && options[:user].id)
        notification.receiver_id = options[:receiver_id] || (options[:receiver] && options[:receiver].id)
        notification.content = options[:content]
        notification.unread = true
        notification.save
    end

    scope :active, -> { where active: true }

    scope :not_read, -> { where unread: true }

end
