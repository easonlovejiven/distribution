class Fx::Level < ActiveRecord::Base
  self.table_name = "fx_levels"
  has_one :upgrade
  scope :active, -> { where :active => true }
  LEVEL=
      {1 => "普通合伙人",
       2 => "高级合伙人",
       3 => "事业合伙人"
      }

  after_create do
    self.build_upgrade.save!
  end

  def dealer1_percent_name
    "#{dealer1_percent}%"
  end

  def dealer2_percent_name
    "#{dealer2_percent}%"
  end

  def dealer3_percent_name
    "#{dealer3_percent}%"
  end

end
