module Entities
  class StatisKpiForUser < Base
    expose :team
    expose :statis_kpi_titles do |ins, options|
      ins.statis_kpi_titles(options[:year])
    end
    expose :statis_kpi_data do |ins, options|
      ins.statis_kpi_data(options[:year])
    end
  end
end
