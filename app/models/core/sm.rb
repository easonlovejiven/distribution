class Core::Sm < ActiveRecord::Base
  establish_connection(Rails.configuration.database_configuration["core"][Rails.env])
  #短信

  validates_presence_of :mobile,:message=>"请输入手机"

  scope :recent, -> { order('created_at DESC')}

  # after_create :send_sms
  attr_accessor :tmpl_vars

  before_save do
    build_content_by_tmpl  if self.tmpl_vars.present?
  end
  
  SORT = {
    :msg=>0,
    :voice=>1
  }

  TEMPLATES =[
      #1用户通过发需求，被动注册
      {optype: "1",number: "1310597",content: %q{【会展邦】恭喜您，成功注册会展邦会员！您的账户为：#code#，密码为：#code#。为了您的账户安全，建议登录会展邦到用户管理中修改登录密码。}}
  ]


  EXPIRES_TIME = 30 * 60
 
  def expires?
    return false if self.state == 1
    return false if self.captchatime < Time.now
    return true
  end

  def send_sms
    mobile  = self.mobile
    if mobile.blank?
      return
    end
    if self.sort == SORT[:msg]
      content = "【会展邦】您的验证码是#{self.captcha}。如非本人操作，请忽略本短信"
      url     = Rails.application.secrets[:sms_url]
      res     = RestClient.post url,{:apikey=>Rails.application.secrets[:sms_apikey],:mobile=>mobile,:text=>content}
      resfs   = JSON.parse(res)
      logger.info("Send User Sms #{mobile} is: #{resfs['msg']}") if resfs['code'] == 0
    else
      voice_url =  Rails.application.secrets[:sms_voice_url]
      @res   = RestClient.post voice_url,{:apikey=>Rails.application.secrets[:sms_apikey],:mobile=>mobile,:code=>self.captcha}
      @resfs   = JSON.parse(@res)
    end
  end

  def success?
   self.state==1
  end

  def send_tmpl_sms!
    raise 'invalid sms parameters' unless !content.blank? && !mobile.blank?
    raise "already sent before" if self.success?
    url     = Settings.sms[:url]
    res     = RestClient.post url,{:apikey=>Settings.sms[:apikey],:mobile=>mobile,:text=>content}
    resfs   = JSON.parse(res)
    if resfs['code'] != 0
      logger.info("Send User Sms #{mobile} is: #{resfs['msg']}")
      raise "send error"
    end
    self.update_attributes!(:state => 1, :send_at => Time.now)
    self
  end

  def build_content_by_tmpl
    @tmpl_vars||=[]
    template=TEMPLATES.detect{|item|item[:optype]==self.optype.to_s}
    self.content=template[:content].gsub(/#code#/).with_index { |m, i| "\"#{@tmpl_vars[i]}\"" }
  end

  def self.find_mobile(account)
    Core::Sm.where(mobile: account).where("captcha is not null").order("id desc").first
  end



  
end
