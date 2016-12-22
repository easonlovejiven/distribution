class Core::Asset < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  validates_presence_of :file, :message => "请输入文件名"

  before_destroy :del_asset

  paginates_per 20
  scope :detail, -> { where(is_default: 0) }
  scope :image_type, ->(type) { where(sort: type) }


  def file_url
    Rails.application.secrets[:qiniu_fx_url] + self.file if self.file.present?
  end

  def img_url
    Rails.application.secrets[:qiniu_fx_url] + self.img if self.img.present?
  end

  def local_file_url
    Rails.application.secrets[:qiniu_fx_url] + self.file if self.file.present?
  end

  private

  def del_asset
    @code, @result, @response_headers = Qiniu::Storage.delete(Rails.application.secrets[:fx_qiniu], self.file) if self.file
  end
end
