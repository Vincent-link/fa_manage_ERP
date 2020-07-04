module Entities
  class StatisKpiForAdmin < Base
    expose :id
    expose :statis_kpi_titles do |ins, options|
      ins.statis_kpi_titles(options[:year])
    end
    expose :statis_kpi_data do |ins, options|
      ins.statis_kpi_data(options[:year])
    end
  end
end
