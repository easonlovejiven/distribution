class Fx::User < ActiveRecord::Base
  self.table_name = "fx_users"
  belongs_to :level
  has_one :info
  has_many :relations, foreign_key: "user_id"
  has_many :invites
  has_many :transations

  belongs_to :account, foreign_key: "id", class_name: "::Core::User"
  has_many :tax_rates

  scope :active, -> { where :active => true }
  scope :recent, -> { order('created_at DESC') }

  mount_uploader :qrcode_image, FxUploader, :mount_on => :qrcode_pic

  attr_accessor :new_user_id
  before_create do
    self.level_id=1
    generate_invitation
  end

  after_create do
    self.build_info.save!
  end

  after_commit on: [:create] do
    QrcodeWorker.perform_async(self.id)
  end

  STATE_NAME = {
      0  => "待激活",
      2  => "审核中",
      1  => "通过",
      -1 => "未通过"
  }

  UPGRADE_STATE             = {
      0 => "正常",
      1 => "待升级"
  }

  #普通合伙人升级额度
  Parter_Normal_Amount_Limit=10

  class<< self
    #上个月获利统计(并扣税)
    def set_last_month_amount
      Fx::User.where(:state => 1).find_each(batch_size: 5000) do |user|
        month_amount=Fx::Transation.where(user_id: user.id, sort: 1).where("created_at >= :start_date AND created_at <= :end_date", {start_date: Time.now.beginning_of_month-1.months, end_date: Time.now.end_of_month-1.months}).sum("amount")
        success     =ActiveRecord::Base.transaction do
          user.info.update!(last_month_amount: month_amount)
          tax_amount=rate_rule(month_amount)
          #上月税金结算
          prev_month=Time.now.prev_month
          date      ="#{prev_month.year}-#{prev_month.month}"
          tax_rate  =Fx::TaxRate.where(user_id: user.id, date: date).first_or_create
          tax_rate.update!({state: 1, amount: tax_amount, total_amount: month_amount})
          #余额转入
          user.income!(month_amount-tax_amount)
          #统计总税金
          user.update_column(:tax_amount, user.tax_rates.sum(:amount))
        end
        raise "统计错误" if !success
      end
    end

    #扣个人所得税
    def rate_rule(amount)
      if amount<=4000
        a=(amount-800)*0.2
        return a<0 ? 0 : a
      end
      if amount>4000 && amount<=20000
        return (amount*(1-0.2))*0.2
      end
      if amount>20000 && amount<=50000
        return (amount*(1-0.2))*0.3
      end
      if amount>50000
        return (amount*(1-0.2))*0.4
      end
    end

    #本月获利统计
    def set_current_month_amount
      Fx::User.where(:state => 1).find_each(batch_size: 5000) do |user|
        #本月获利
        month_amount=Fx::Transation.where(user_id: user.id).where("created_at >= :start_date AND created_at <= :end_date", {start_date: Time.now.beginning_of_month, end_date: Time.now.end_of_month}).sum("amount")
        user.info.update!(current_month_amount: month_amount)
        #本月税金计算
        current_month="#{Time.now.year}-#{Time.now.month}"
        tax_rate     =Fx::User.rate_rule(month_amount)
        rate         =Fx::TaxRate.where(user_id: user.id, date: current_month).first_or_create
        rate.update(total_amount: month_amount, amount: tax_rate, state: 0)
      end
    end

    #万人总排名
    def set_rank
      Fx::User.where(:state => 1).order("total_amount desc").limit(10000).each_with_index do |user, index|
        user.update!(rank: index+1)
      end
    end

    #当前省份排名
    def set_province_rank
      Core::User.all.each do |account|
        Fx::User.where(id: account.id).update_all({province_id: account.province_id})
      end
      Fx::User.where(:state => 1).where("province_id is not null").group_by { |item| item.province_id }.each do |key, items|
        items.sort_by { |item| -item.total_amount }.each_with_index do |user, index|
          user.update(province_rank: index+1)
        end
      end
    end

    #下属分销商数量统计
    def set_dealer_count
      Fx::User.where(:state => 1).find_each(batch_size: 1000) do |user|
        dealer1_count=user.level1_dealers.count
        dealer2_count=user.level2_dealers.count
        dealer3_count=user.level3_dealers.count
        dealer_count =dealer1_count+dealer2_count+dealer3_count
        user.info.update({dealer_count: dealer_count, dealer1_count: dealer1_count, dealer2_count: dealer2_count, dealer3_count: dealer3_count})
      end
    end

    #生成二维码图片
    def genrate_qrcode_pic(user_id)
      user   =Fx::User.find(user_id)
      url    =user.invitation_url
      qrcode = RQRCode::QRCode.new(url)

      png = qrcode.as_png(
          resize_gte_to:     false,
          resize_exactly_to: false,
          fill:              'white',
          color:             'black',
          size:              200,
          border_modules:    2,
          module_px_size:    6,
          file:              nil # path to write
      )
      # file=IO.write("/tmp/fx-qrcode.png", png)
      key ="qrcode/#{user.id}#{Time.now.to_i}qrcode.png"
      FileUtils.mkdir_p("/tmp/qrcode")
      tmp_path="/tmp/#{key}"
      tmp_file=File.open(tmp_path, "w:UTF-8") do |f|
        f.write(png.to_s.force_encoding("UTF-8"))
      end
      # user.qrcode_image=png.to_s.force_encoding("UTF-8")
      Qiniu.upload_file({:uptoken => Qiniu.generate_upload_token,
                         :file    => tmp_path,
                         :bucket  => "hzb-fx",
                         :key     => key,
                         # :mime_type => mime_type,
                         # :enable_resumable_upload=>true
                        })
      user.update!(qrcode_pic: key)
      File.delete(tmp_path)
    end


    #邀请用户注册
    def add_invitation_users(user, invitation)
      used_byer   = Fx::User.find_by_invitation(invitation)
      new_level_id=case used_byer.level.id
                   when 2
                     1
                   when 3
                     2
                   when 4, 5, 6, 7, 8
                     3
                   end
      invite      = user.invites.new(:used_by => used_byer.id)
      user.update!(level_id: new_level_id) if new_level_id.present?
      Fx::Relation.create!(user_id: used_byer.id, dealer_id: user.id)
      invite.save!
    end
  end


  def state_name
    STATE_NAME[self.state]
  end


  #所属上一级分销商
  def prev_dealer
    relation=Fx::Relation.where(dealer_id: self.id).first
    relation.present? ? relation.user : nil
  end

  #一级分销商
  def level1_dealers
    Fx::Relation.where(user_id: self.id)
  end

  #二级分销商
  def level2_dealers
    dealer_ids=level1_dealers.map(&:dealer_id)
    Fx::Relation.where(user_id: dealer_ids)
  end

  #三级分销商
  def level3_dealers
    dealer_ids=level2_dealers.map(&:dealer_id)
    Fx::Relation.where(user_id: dealer_ids)
  end

  #升级状态
  def upgrade_state_html
    if self.upgrade_state==1
      return "<span class='txt-color-red'>升级(#{level.name})，待审核<span>".html_safe
    else
      return "正常"
    end
  end

  #=======实时获利实时提现todo========
  #个人扣税计算
  def month_rate_rule(amount)
    if self.month_withdraw==0
      current_tax=Fx::User.rate_rule(amount)
    else
      month_tax         =Fx::User.rate_rule(self.info.current_month_amount)
      month_withdraw_tax=Fx::User.rate_rule(self.month_withdraw)
      current_tax       =month_tax-month_withdraw_tax
    end
    current_tax
  end

  #此次最少提现金额(大于扣税金额)
  def limit_withdraw_amount
    self.info.current_month_amount
  end

  #=======实时获利实时提现todo========

  #本月累计提现金额
  def month_withdraw
    Core::BangWithdraw.where(user_id: self.id, state: 1).where("created_at >= :start_date AND created_at <= :end_date", {start_date: Time.now.beginning_of_month, end_date: Time.now.end_of_month}).sum(:price)
  end

  #是否可保级
  def upgrade_level
    upgrades=[]
    Fx::Level.order(sort: :asc).each do |level|
      upgrade=level.upgrade
      result =true
      #金额是否满足升级
      if before_month_amount(upgrade.month)<upgrade.amount
        result=false
      end
      #下级分销商数量是否满足升级
      if self.info.dealer_count<upgrade.count
        result=false
      end
      if result
        upgrades<<upgrade
      end
    end
    if upgrades.last
      upgrades.last.level
    end
  end

  #保级还差金额
  def prevent_level_amount
    if self.normal_parter?
      if Fx::User::Parter_Normal_Amount_Limit>self.info.current_month_amount
        Fx::User::Parter_Normal_Amount_Limit-self.info.current_month_amount
      else
        return 0
      end
    else
      nil
    end
  end

  #是否为普通合伙人角色
  def normal_parter?
    self.level.id==4
  end


  #是否可以解除分销关系
  def remove_relationable?
    true
  end

  #解除分销关系
  def remove_relation
    ActiveRecord::Base.transaction do
      relations.update_all(user_id: nil, old_user_id: self.id)
      self.update!(is_remove_relation: true)
    end
  end

  #从新绑定分销关系
  def update_relation(new_user_id)
    ActiveRecord::Base.transaction do
      remove_relation
      Fx::Relation.where(user_id: self.id).where("dealer_id!=#{new_user_id}").update_all(user_id: new_user_id, old_user_id: nil)
      Fx::Relation.where(old_user_id: self.id).where("dealer_id!=#{new_user_id}").update_all(user_id: new_user_id, old_user_id: nil)
      self.update!(is_remove_relation: false)
    end
  end

  #解除所属上一级分销商
  def remove_prev_relation
    ActiveRecord::Base.transaction do
      re=Fx::Relation.where(dealer_id: self.id).update_all(user_id: nil)
    end
  end

  #更新所属上一级分销上
  def update_prev_relation(new_user_id)
    ActiveRecord::Base.transaction do
      re=Fx::Relation.where(dealer_id: self.id).first_or_create
      re.update({user_id: new_user_id})
    end
  end

  #万人区第一名的奖金差距
  def distance_amount
    rank            = self.rank == 1 ? 1 : self.rank-1
    top_total_amount=Fx::User.where(rank: rank).first.try(:total_amount).to_f
    top_total_amount-total_amount if top_total_amount>=total_amount
  end

  #省区第一名的奖金差距
  def distance_province_amount
    province_rank   = self.province_rank == 1 ? 1 : self.province_rank-1
    top_total_amount=Fx::User.where(province_rank: province_rank).first.try(:total_amount).to_f
    top_total_amount-total_amount if top_total_amount>=total_amount
  end

  def name
    account.try(:nickname)
  end

  def generate_invitation
    loop do
      self.invitation = st(6)
      break unless Fx::User.find_by(invitation: self.invitation)
    end
  end

  def st(length=2)
    chars  = 'abcdefghjkmnpqrstuvwxz12345678'
    string = ''
    length.downto(1) { |i| string << chars[rand(chars.length - 1)] }
    string
  end

  def income!(amount)
    self.account.active_hfbpay
    self.balance                   +=amount
    self.account.hfbpay.bang_amount+=amount
    self.account.hfbpay.save!
    self.save!
  end

  def outcome!(amount)
    self.account.active_hfbpay
    self.balance                   -=amount
    self.account.hfbpay.bang_amount-=amount
    self.account.hfbpay.save!
    self.save!
  end

  def invitation_url
    "#{Rails.application.secrets[:domain]}/fx/signup?invitation=#{self.invitation}"
  end

  def invitation_qrcode
    self.qrcode_image.url
  end

  def remain_user_num
    Fx::Setting.first.apply[:remain]
  end

  #前几个月的获利金额
  def before_month_amount(m)
    Fx::Transation.where(user_id: self.id, sort: 1).where("created_at >= :start_date AND created_at <= :end_date", {start_date: Time.now.beginning_of_month, end_date: Time.now.end_of_month-m.send(:months)}).sum("amount")
  end

  def active_hfbpay
    unless self.account.try(:hfbpay)
      hfbpay = self.account.build_hfbpay(current_amount: 0)
      hfbpay.save!
    end
  end

  #当前月税金
  # def current_month_tax
  #   current_month="#{Time.now.year}-#{Time.now.month}"
  #   rate_amount  =self.class.rate_rule(self.current_month_amount)
  #   {amount: rate_amount, total_amount: self.current_month_amount, date: current_month, state: 0}
  # end

  def withdraw_coding
    "TX#{self.id}#{Time.now.to_i}"
  end

  #是否公司员工
  def is_employee
    Fx::Employee.where(id: self.id).first
  end


  def level_name
    level.try(:name)
  end

  def info_dealer1_count
    info.try(:dealer1_count)
  end

  def add_relation(new_user_id)
    ActiveRecord::Base.transaction do
      @fx_user = Fx::User.where(id: new_user_id).first
      Fx::User.add_invitation_users(self, @fx_user.invitation) if @fx_user
    end
  end

  self.json_options={
      :only    => ["id", "user_id", "total_amont", "balance", "current_amount", "total_amount", "rank", "tax_amount", "province_rank"],
      :methods => [:prevent_level_amount, :distance_amount, :distance_province_amount, :invitation_url],
      :include => {
          account: {:only => [:id, :nickname], methods: [:bang_amount, :avatar_url, :province_name, :city_name]},
          info:    {:only => [:amount, :amount1, :amount2, :amount3, :dealer_count, :dealer1_count, :dealer2_count, :dealer3_count, :current_month_amount]},
          level:   {:only => [:id, :name]}
      }
  }

end
