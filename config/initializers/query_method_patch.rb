#encoding:utf-8
module ActiveRecord
  class Base
    class << self
      delegate :time_filter, :to => :scoped
    end
  end
  module QueryMethods
    def time_filter(filter_name, time_name = "created_at")
      case filter_name
      when "today"
        where("#{time_name} >= ?", Time.now.beginning_of_day)
      when "yesterday"
        temp_time = Time.now.beginning_of_day
        where("#{time_name} >= ? and #{time_name} < ?", temp_time - 1.days, temp_time)
      when "this_week"
        where("#{time_name} >= ?", Time.now.beginning_of_week)
      when "last_week"
        temp_time = Time.now.beginning_of_week
        where("#{time_name} >= ? and #{time_name} < ?", temp_time - 1.weeks, temp_time)
      when "this_month" #本月
        where("#{time_name} >= ?", Time.now.beginning_of_month)
      when "pre_month" # 上月
        temp_time = Time.now.beginning_of_month
        where("#{time_name} >= ? and #{time_name} < ?", temp_time - 1.months, temp_time)
      when "last_month" #前月
        temp_time = Time.now.beginning_of_month
        where("#{time_name} >= ? and #{time_name} < ?", temp_time - 2.months, temp_time - 1.months)
      else
        clone
      end
    end
  end
end
