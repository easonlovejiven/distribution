module AdminHelper

  def model
    @model ||= self.controller.model
  end

  def time_format(date)
    date.strftime("%Y-%m-%d %H:%M")
  end

  def datetime_format(date)
    date.strftime("%Y-%m-%d")
  end


  def format_yes_no(val)
    return "未知" if val.nil?
    val==true ? "是" : "否"
  end

  def format_gender(val)
    gender = ['女', '男'][val]
    gender.blank? ? '未知' : gender
  end

  def search_field_kv(*keys)
    kv = {k: 'where', v: params[:where]}
    keys.flatten.each { |key| kv[:k]="#{kv[:k]}[#{key}]"; kv[:v] = kv[:v].try(:[], key) }
    kv[:k] = kv[:k].to_s.gsub('%', '')
    kv
  end

  def order_field_kv(*keys)
    kv = {k: 'order', v: params[:order]}
    keys.flatten.each { |key| kv[:k]="#{kv[:k]}[#{key}]"; kv[:v] = kv[:v].try(:[], key) }
    kv[:k] = kv[:k].to_s.gsub('%', '')
    kv
  end

  def order_link_btn(field)
    html = ''.html_safe
    val = params[:order].try(:[], field.to_s).to_s.downcase
    if val != 'asc'
      html += link_to('↑', {order: {field => 'asc'}})
    end
    if val != 'desc'
      html += link_to('↓', {order: {field => 'desc'}})
    end
    html
  end
end
