module Entities
  class TeamForStatis < Base
    expose :id
    expose :titles do |team|
      arr = []

      titles = team.users.map(&:kpi_group).compact.map(&:kpis).flatten.pluck(:kpi_type).uniq

      titles.unshift("成员名称")
      titles.append("成员id")
      titles.map { |title|
        row = {}
        row[title] = title
        arr << row
      }

      # if !titles.users.empty?
      #   titles.unshift("成员名称")
      # else
      #   []
      # end
      arr
    end
    expose :user_kpis do |team|
      arr = []
      team.users.joins(:kpi_group).map {|user|
        row = {}
        user.kpi_group.kpis.map {|kpi|
          if kpi.conditions.empty?
            team.users.map(&:kpi_group).compact.map(&:kpis).flatten.pluck(:kpi_type).uniq.map{|type|
              row["类型#{type}"] = "2/#{kpi.value}" if kpi.kpi_type == type
            }
          else
            team.users.map(&:kpi_group).compact.map(&:kpis).flatten.pluck(:kpi_type).uniq.map{|type|
              row["类型#{type}"] = "2/#{kpi.value} #{kpi.conditions.map{|e| "#{e.relation} 2/#{e.value}"}.join(" ")}" if kpi.kpi_type == type
            }
          end
        }

        new_row = {"成员名称": user.name}.merge(row)
        new_row = new_row.merge({"成员id": user.id})
        arr << new_row
      }
      arr
    end
  end
end
