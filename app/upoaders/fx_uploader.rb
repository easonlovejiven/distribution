# encoding: utf-8
class FxUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  #storage :file
  storage :qiniu

  def initialize(*)
    super
    self.class.qiniu_bucket=Rails.application.secrets[:qiniu_fx]
    self.class.qiniu_bucket_domain=Rails.application.secrets[:qiniu_fx_domain]
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    ""
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    if file=Rails.application.assets.find_asset(["blank/avatar", "#{version_name}.png"].compact.join('_'))
      ActionController::Base.helpers.asset_path("/assets/" + file.digest_path)
    end
  end

  version :tiny, :if => :has_version? do
    process :resize_to_fit => [50, 50]

    def full_filename (for_file = model.logo.file)
      "#{for_file}-tiny"
    end
  end

  version :thumb, :if => :has_version? do
    process :resize_to_fit => [100, 100]

    def full_filename (for_file = model.logo.file)
      "#{for_file}-thumb"
    end
  end

  # Create different versions of your uploaded files:
  version :medium, :if => :has_version? do
    process :resize_to_fit => [200, 200]

    def full_filename (for_file = model.logo.file)
      "#{for_file}-medium"
    end
  end

  version :big, :if => :has_version? do
    process :resize_to_fit => [600, 600]

    def full_filename (for_file = model.logo.file)
      "#{for_file}-big"
    end
  end

  version :content, :if => :has_version? do
    process :resize_to_fit => [800, 800]

    def full_filename (for_file = model.logo.file)
      "#{for_file}-content"
    end
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if original_filename
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.jpg"
    end
  end

  def has_version?(new_file)
    !storage.is_a?(CarrierWave::Storage::Qiniu)
  end

end
