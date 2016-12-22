class Manage::Editor < ActiveRecord::Base
  self.table_name = "manage_editors"
  belongs_to :user, foreign_key: 'id',class_name: "Manage::User"
  belongs_to :account,foreign_key: 'id',class_name: "Core::User"
  # belongs_to :department, class_name: Office::Human::Department
  belongs_to :creator, -> { where active: true }, class_name: "Manage::Editor", foreign_key: "creator_id"
  belongs_to :updater, -> { where active: true }, class_name: "Manage::Editor", foreign_key: "updater_id"

  belongs_to :role, -> { where active: true }
  has_many :grants, -> { where active: true }
  has_many :roles, through: :grants
  belongs_to :supervisor, -> { where active: true }, foreign_key: 'supervisor_id', class_name: Manage::Editor
  has_many :subordinates, -> { where active: true }, foreign_key: :supervisor_id, class_name: Manage::Editor

  accepts_nested_attributes_for :grants, reject_if: -> (attr) { !attr['id'] && attr['active'] == '0' }

  DEPARTMENTS = %w[产品技术部 市场部 财务部 人力资源部 客服部 行政部 ]
  POSITION = {'staff' => '员工', 'human' => '人事', 'finance' => '财务', 'department' => '部门主管', 'manager' => '总经理', 'ceo' => 'CEO', 'director' => '董事长'}
  # validates_existence_of :user
  validates_uniqueness_of :name, :scope => :active, :if => Proc.new { |record| record.active? }, :allow_blank => true
  validates_uniqueness_of :identifier, :scope => :active, :if => Proc.new { |record| record.active? }, :allow_blank => true
  # validates_inclusion_of :department_id, :in => Office::Human::Department.all.active.pluck(:id), :allow_blank => true
  validates_associated :grants

  scope :active, -> { where active: true }

  def deletable? #:nodoc: all
    self.subordinates.empty?
  end

  cattr_accessor :manage_fields do
    %w[ id name identifier department_id supervisor_id user_id role_id position grants_attributes prefix ] << {grants_attributes: %w{ active role_id id editor_id}};
  end
end
