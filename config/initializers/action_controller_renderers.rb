ActionController::Renderers.add :csv do |obj, options|
  str = "\357\273\277" << obj.map(&:to_csv).join
  send_data str, :type => Mime::CSV, :disposition => "attachment; filename=#{options[:filename] || 'export'}.csv"
end

ActionController::Renderers.add :tsv do |obj, options|
  str = "\357\273\277" << obj.map(&:to_csv).join.gsub(',', "\t")
  send_data str, :type => Mime::TSV, :disposition => "attachment; filename=#{options[:filename] || 'export'}.tsv"
end

ActionController::Renderers.add :xls do |obj, options|
  obj.map! { |l| l.map { |c| c.is_a?(Time) || c.is_a?(Date) ? c.to_s(:db) : c } }
  xls = Spreadsheet::Workbook.new
  sheet = xls.create_worksheet
  obj.each_with_index do |line, index|
    sheet.update_row index, *line
  end
  io = StringIO.new
  xls.write(io)
  io.rewind
  str = io.read
  io.close
  send_data str, :type => Mime::XLS, :disposition => "attachment; filename=#{options[:filename] || 'export'}.xls"
end
