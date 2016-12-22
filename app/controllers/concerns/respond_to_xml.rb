module RespondToXml
  def respond_to_xml
    r_format = request.format && request.format.to_sym || ''
    return yield unless %w[xml json yaml].include?(r_format.to_s)
    request.format, params[:_format] = :xml, r_format
    # unless request.format.to_sym.in? self.collect_mimes_from_class_level
    begin
      yield
    rescue => e
      unless e.is_a?(ActionView::MissingTemplate)
        @data = {:error => {:code => ERROR_TABLE[e.class.to_s], :type => e.class.to_s, message: e.message}}
        logger.warn %[#{e.class.to_s}: #{e.message}\n#{e.backtrace.map { |s| "\tfrom #{s}\n" }.join}]
      end
      render :template => "layouts/common/application", :formats => [params[:_format].to_sym]
    end

    request.format = params.delete(:_format)
    response.content_type = request.format.to_s
  end
end
