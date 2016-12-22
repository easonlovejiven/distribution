class Fx::Employee < ActiveRecord::Base
  self.table_name = "fx_employees"
  belongs_to :user,foreign_key: "id"
  ROLE_PERCENT    ={
      0 => 2,
      1 => 2,
      2 => 3,
      3 => 5,
      4 => 5,
      5 => 5
  }
  ROLE_NAME       ={
      0 => "助理",
      1 => "经理",
      2 => "总监",
      3 => "部长",
      4 => "总经理",
      5 => "总经理以上"
  }

  def self.role_name_percent
    hash={}
    ROLE_NAME.each{|k,v| hash[k]="#{v}#{ROLE_PERCENT[k]}%"}
    hash
  end

  def role_name
    ROLE_NAME[role]
  end

  def percent
    ROLE_PERCENT[role]
  end

  def percent_display
      "#{percent}%"
  end

end