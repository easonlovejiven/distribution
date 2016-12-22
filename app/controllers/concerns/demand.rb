module Demand
  def respond_on_demand
    # return unless request.format && request.format.html? && params[:controller] =~ /^develop\/document/
    if request.env["HTTP_USER_AGENT"].to_s =~ /iphone|ipod|ipad|Mobile|webOS/i
      if params[:subdomain]!="m"
        puts "######{params[:subdomain]}"
        redirect_to(Rails.application.secrets["mobile_domain"]) && return
      end
    end
  end
end
