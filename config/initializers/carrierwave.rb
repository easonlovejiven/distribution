module CarrierWave
  module RMagick
    # Reduces the quality of the image to the percentage given
    def quality(percentage)
      manipulate! do |img|
        img.write(current_path) { self.quality = percentage } unless img.quality == percentage
        img = yield(img) if block_given?
        img
      end
    end

    # Rotates the image based on the EXIF Orientation
    def fix_exif_rotation
      manipulate! do |img|
        img.auto_orient!
        img = yield(img) if block_given?
        img
      end
    end
  end

  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

CarrierWave.configure do |config|
  config.storage = :qiniu
  config.qiniu_access_key = Rails.application.secrets[:qiniu_access_key]
  config.qiniu_secret_key = Rails.application.secrets[:qiniu_secret_key]
  config.qiniu_bucket = Rails.application.secrets[:qiniu_fx]
  config.qiniu_bucket_domain = Rails.application.secrets[:qiniu_fx_domain]
end

Qiniu.establish_connection! :access_key => Rails.application.secrets[:qiniu_access_key],
                                :secret_key => Rails.application.secrets[:qiniu_secret_key],
                                :content_type => 'multipart/form-data'
