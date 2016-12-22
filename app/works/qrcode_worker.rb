class QrcodeWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :fx_count, :retry => 3
  qrcode = RQRCode::QRCode.new("http://github.com/")
# With default options specified explicitly
  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform(user_id)
    Fx::User.genrate_qrcode_pic(user_id)
  end

end