module Formatters::StatXlsFormatter
  def self.call(object, _env)
    xls_data = []
    case _env['rack.request.query_hash']['stat_type']
    when 'funding_stat'
      xls_data <<
          ['', '参与统计项目数', '交互投资机构总数', '交互投资机构平均数', '交互投资机构中位数', '已出TS总数', '已出TS平均数', '已出TS中位数', '已签署SPA总数', '已签署SPA平均数', '已签署SPA中位数', 'Pass总数', 'Pass平均数', 'Pass中位数', 'Drop总数', 'Drop平均数', 'Drop中位数']
      object[:stat].each do |ins|
        xls_data << [ins['row_name'], ins['funding']].concat(ins['org']).concat(ins['ts']).concat(ins['spa']).concat(ins['pass']).concat(ins['drop'])
      end
    when 'fundings'
      object = object.as_json
      xls_data << ['项目名称', '项目状态', '推荐机构数', '已出TS数', '已签署SPA数', '项目执行天数']
      xls_data << ['全部项目平均', '', object[:avg][:avg], object[:avg][:ts_avg], object[:avg][:spa_avg], object[:avg][:days_avg]]
      object[:fundings].each do |ins|
        xls_data << [ins[:name], ins[:status], ins[:tic_count], ins[:ts_count], ins[:spa_count], ins[:execution_days]]
      end
    when 'organizations'
      object = object.as_json
      xls_data << ['投资机构名称', '交互项目数', '正在交互的项目数', '已出TS项目数', '已签署SPA项目数', 'Pass项目数', 'Drop项目数']
      xls_data << ['全部机构平均值', object[:avg][:avg], object[:avg][:funding_avg], object[:avg][:ts_avg], object[:avg][:spa_avg], object[:avg][:pass_avg], object[:avg][:drop_avg]]
      object[:organizations].each do |ins|
        xls_data << [ins[:name], ins[:funding_count], ins[:on_going_count], ins[:ts_count], ins[:spa_count], ins[:pass_count], ins[:drop_count]]
      end
    end
    File.read Common::ExcelGenerator.gen_binary({'sheet1' => xls_data})
  end
end