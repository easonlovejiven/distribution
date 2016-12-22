class ActiveRecord::Base
  def self._where(params)
    params=case
             when params.is_a?(String); #params
             when params.is_a?(Array); #params
             when params.is_a?(Hash)
               params = params.map do |field, condition|
                 condition = case
                               when condition.is_a?(Hash);
                                 condition
                               when condition.is_a?(Range);
                                 {'>=' => condition.begin, '<=' => condition.end}
                               when condition.is_a?(Array);
                                 {'in' => condition.reject{|i|i.blank?}}
                               else
                                 ; {'=' => condition}
                             end
                 condition.reject!{|k,v|v.blank?}
                 condition.map do |operator, value|
                   {%[''] => '', %[""] => '', 'true' => true, 'false' => false, 'nil' => nil, 'null' => nil}.each { |x, y| value = y if value == x }
                   operator = {'eq' => '=', 'lt' => '<', 'gt' => '>', 'gteq' => '>=', 'lteq' => '<=', 'noteq' => '!='}[operator] || operator
                   operator = {'=' => 'is', '!=' => 'is not'}[operator] if value === nil
                   raise unless field.to_s =~ /^(?:[`'"]?(\w+)[`'"]?\.)?[`'"]?(\w+)[`'"]?$/ && (%w[= > < >= <= != in like is]+['is not']).include?(operator)
                   if operator=="like"
                     ["#{field} #{operator} ?", "%#{value}%"]
                   else
                     ["#{field} #{operator} #{value.is_a?(Array) ? '(?)' : '?'}", value]
                   end
                 end.compact
               end
               params.inject([], &:+).inject { |a, b| a[0] = [a[0], b[0]].join(' AND '); a << b[1]; a }
           end
    where(params)
  end

  def self._order(params)
    params = case
               when params.blank?;
                 "id DESC"
               when params.is_a?(Hash);
                 params.map { |field, order| "#{field} #{order}" }.join(',')
               when params.is_a?(Array);
                 params.join(',')
               else
                 params
             end
    raise unless "#{params},".match(/^(?:\s*(?:[`'"]?(\w+)[`'"]?\.)?[`'"]?(\w+)[`'"]?\s*(\sasc|\sdesc)?\s*,\s*)*$/i)
    order(params)
  end
end
