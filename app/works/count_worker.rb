#统计上月获利
class CountLastMonthWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :fx_count, :retry => 3
  include Sidetiq::Schedulable

  recurrence { monthly(1) }

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform
    Fx::User.set_last_month_amount
    Core::Hfbpay.set_total_bang_amount
  end
end

#统计当月获利
class CountMonthWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :fx_count, :retry => 3
  include Sidetiq::Schedulable

  recurrence { minutely(2) }

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform
    Fx::User.set_current_month_amount
  end
end

#统计排名
class Count1HourWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :fx_count, :retry => 3
  include Sidetiq::Schedulable

  recurrence { hourly(1) }

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform
    Fx::User.set_rank
    Fx::User.set_province_rank
  end
end

#统计下属分销商数量
class CountFxUserWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :fx_count, :retry => 3
  include Sidetiq::Schedulable

  recurrence { minutely(10) }

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform
    Fx::User.set_dealer_count
  end
end

#自动审核15分钟
class AutoAuditFxUserWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :fx_count, :retry => 3
  include Sidetiq::Schedulable

  recurrence { minutely(15) }

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform
    if audit_setting=Fx::Setting.where(key: "audit_type").first
      if audit_setting.value=="2"
        setting = Fx::Setting.where(key: "audit_cost_amount").first
        Fx::User.where(:state => [0, 2]).find_each(batch_size: 5000) do |user|
          user.update({state: 1}) if user.cost_amount>=setting.value.to_i
        end
      end
    end
  end
end

#升级状态
class UpgradeFxUserWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :fx_count, :retry => 3
  include Sidetiq::Schedulable

  recurrence { minutely(10) }

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform
    Fx::User.where(:state => 1).find_each(batch_size: 5000) do |user|
      user.update(upgrade_state: 1) if user.upgrade_level
    end
  end
end