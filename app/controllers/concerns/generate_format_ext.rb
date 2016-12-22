module GenerateFormatExt

  def generate_tabulation(fields = [], records = [])
    [fields.map { |f| f[:name] }]+records.map { |r| fields.map { |f|
      !((p = f[:permission]) && p.is_a?(Proc) ? p.call(@current_user) : p.is_a?(Symbol) ? @current_user.send(p) : true) ? '/' :
          (v = f[:value]) && v.is_a?(Proc) ? v.call(r) :
              v.is_a?(Symbol) ? r.send(v) :
                  v
    } }
  end

  def generate_csv(table)
    table.map! { |l| l.map { |c|
      c.is_a?(String) && c =~ /^[\d\.+-]+$/ ? "\t#{c}" :
          c.is_a?(Time) || c.is_a?(Date) ? c.to_s(:db) :
              c
    } }
    %[\357\273\277#{table.map(&:to_csv).join}]
  end

  def generate_tsv(table)
    table.map! { |l| l.map { |c|
      c.is_a?(String) && c.match(/\t|\r|\n/) ? '/' :
          c.is_a?(Time) || c.is_a?(Date) ? c.to_s(:db) :
              c
    } }
    %[\357\273\277#{table.map { |l| l.join("\t") }.join("\r\n")}]
  end

  def generate_xls(table)
    table.map! { |l| l.map { |c|
      c.is_a?(Time) || c.is_a?(Date) ? c.to_s(:db) :
          c
    } }
    xls = Spreadsheet::Workbook.new
    sheet = xls.create_worksheet
    table.each_with_index do |line, index|
      sheet.update_row index, *line
    end
    io = StringIO.new
    xls.write(io)
    io.rewind
    io.read
  end

  def generate_table(table)
    table.map! { |l| l.map { |c|
      c.is_a?(String) && c.match(/\.(jpg|jpeg|png|gif)(\?\d*)?$/) ? %[<a href="http://#{[::HOSTS['image']].flatten.first}#{c.sub(/https?:\/\//, '')}"><img src="http://#{[::HOSTS['image']].flatten.first}#{c.sub(/https?:\/\//, '')}" style="max-width: 100px; max-height: 100px;" /></a>] :
          c.is_a?(String) && c.match(/^\w+\:\/\//) ? %[<a href="#{c}">#{c}</a>] :
              c.is_a?(String) ? c.gsub(/[\r\n]+/, "\n") :
                  c.is_a?(Time) || c.is_a?(Date) ? c.to_s(:db) :
                      c.to_s
    } }
    %[\357\273\277<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>表格</title></head><body><table><tbody>#{table.each_with_index.map { |l, i| l.each_with_index.map { |c, j| i == 0 || j == 0 ? "<th>#{c}</th>" : "<td>#{c}</td>" }.join }.map { |l| "<tr>#{l}</tr>" }.join }</tbody></table></body></html>]
  end
end
