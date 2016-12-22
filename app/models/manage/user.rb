class Manage::User < ActiveRecord::Base
  self.table_name=:manage_users
  # has_one :employee, foreign_key: 'id', class_name: 'Office::Human::Employee'
  has_many :notifications, foreign_key: 'receiver_id', class_name: 'Manage::Notification'
  belongs_to :editor, foreign_key: 'id', class_name: '::Manage::Editor'
  scope :active, -> { where active: true }

  #has_many :notifications
  # has_many :dailies, foreign_key: 'creator_id', class:  Office::Human::Daily
  # has_many :vacations, -> { where active: true }, class_name: 'Office::Vacation::Apply'

  GENDER = {male: '男', female: '女'}

  cattr_accessor :manage_fields do
    %w{name login_at birthday gender pic};
  end

  def self.acquire(id)
    puts  "========#{id}"
    record = self.find_by_id(id)
    if !record || record.updated_at < 1.day.ago
      u = Manage::User.find_by_id(id)
      (record = self.new; record.id = u.id, record.name = u.name, record.birthday = u.birthday, record.gender = u.gender) unless record
      record.login_at = Time.now
      record.save
    end

    record
  end

  def can?(action, resource)
    return false unless editor.try(:active?)
    resource = resource.scoped.klass if resource.respond_to?(:scoped)
    resource = resource.class if resource.is_a?(ActiveRecord::Base)
    resource = resource.to_s.underscore.gsub('/', '_')
    @roles ||= (editor.roles.active + [editor.role]).uniq.compact
    @roles.map { |role| role.can?(action, resource) }.inject(false, &:|)
  end

  def method_missing_with_privilege(method, *args)
    if m = method.to_s.match(/^can_([^\_]+)_([^\?]+)\??/)
      return true
      return self.can?(m[1], m[2])
    end

    method_missing_without_privilege(method, *args)
  end

  alias_method_chain :method_missing, :privilege

  def is_role?(role_name)
    self.editor.role.name.eql?(role_name)
  end
end
