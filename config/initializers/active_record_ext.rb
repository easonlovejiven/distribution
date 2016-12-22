class ActiveRecord::Base
  # def read(options={})
  #   self.readings.create(options)
  # end

  def cgi_escape_action_and_options(action, options) # :nodoc: all
    "#{action}?#{options.sort.map { |k, v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}" }.join('&')}"
  end

  def cgi_escape_options(options)
    options.sort.map { |k, v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}" }.join('&')
  end

  def destroy_softly
    self.active = false
    # self.destroyed_at = Time.now
    self.save #_without_validation#_and_timestamping
  end
  #
  # def remote_ip
  #   user_id = case self.class.name
  #               when "Core::Account"
  #                 self.id
  #               when "Core::Feed"
  #                 self.source_id
  #               else
  #                 self.user_id
  #             end
  #
  #   login = user_id && self.created_at && Core::Login.find_by_user_id_and_login_on(user_id, self.created_at.to_date)
  #   login && login.ip_address
  # end

  def self.default(params, options = {})
    active
        ._where(params[:where])
        ._order(params[:order])
        .page(params[:page]).per(params[:per_page])
  end

  def self.f(id)
    record = where(id: id)
    record = record.where(active: true) if record.first.respond_to?(:active?)
    record.first
  end

  def self.acquire(id)
    f(id)
  end
end

#
# module ActiveModel
#   module Serializers
#     module Xml
#       class Serializer
#         def add_associations_with_undasherize(association, records, opts)
#           opts = (opts || {}).merge(:dasherize => false)
#           add_associations_without_undasherize(association, records, opts)
#         end
#
#         alias_method_chain :add_associations, :undasherize
#       end
#     end
#   end
# end
