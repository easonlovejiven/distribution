class Admin::AssetsController <  Admin::ApplicationController
  protect_from_forgery except: [:uptoken,:uploads,:updone,:updone_save]
  # before_filter :authenticate_admin_user,except: [:uptoken,:uploads,:updone,:updone_save]

  def upload
    @filename = params[:key]
    if @filename
      @sort = params[:type].split('-').second
      user = Core::User.find(params[:user_id])
      old_asset = user.assets.image_type(@sort).first
      old_asset.destroy if old_asset.present?
      @asset =  user.assets.create!(:file=> params[:key],:sort=>@sort)
      @file_url =   Rails.application.secrets[:qiniu_fx_url] + @filename
      respond_to do |format|
        format.js
        format.xml{ render json: {file_url: @file_url },status: 200}
      end
    end
  end

  def updone
    @filename = params[:key]
    if @filename
      @file_url =  Rails.application.secrets[:qiniu_fx_url] + @filename
      respond_to do |format|
        format.js
        format.xml{ render json: {file_url: @file_url },status: 200}
      end
    end
  end

  def updone_save
    filename = params[:key]
    if filename
      @asset =  Core::Asset.new(:file=>filename)
      if @asset.save!
        respond_to do |format|
          format.js
          format.xml{ render json: @asset, status: 200 }
        end
      end
    end
  end
 

  def del
    @asset_id =  params[:asset_id]
    @asset =  Core::Asset.find(@asset_id)
    if @asset.destroy
      respond_to do |format|
        format.js
      end
    end
  end


  #上传到 空间
  def uptoken
    bucket = Rails.application.secrets[:qiniu_fx]
    render json: {uptoken: Qiniu::Auth.generate_uptoken(put_policy(bucket))}
  end

  def file_keys
    uploads = Core::Asset.all
    @uploads = uploads.offset(params[:start]||0).limit(params[:size]||10).order('id desc')
    render json: {state: 'SUCCESS', list: @uploads.as_json(only:[:id,:file]), start: params[:start]||0, total: uploads.count}
  end

  private
  
  def file_url(filename)
    Settings.qiniu['domain'] + filename
  end
  
end
