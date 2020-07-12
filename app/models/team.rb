class Team < DefaultTeam
  has_many :users
  has_many :kpi_groups

  has_many :sub_teams, class_name: "Team", foreign_key: :parent_id

  def statis_kpi_titles(year)
    arr = []
    titles = kpi_types(year)

    arr.unshift({"member_name": "成员名称"})
    titles.pluck(:id, :kpi_type).uniq.map { |title|
      row = {}
      # 如果kpi没有条件，显示自己的desc和描述，如果有条件，显示条件的statis_title和描述
      row[title[1]] = Kpi.kpi_type_desc_for_value(title[1])
      row[title[1]] = Kpi.find(title[0]).conditions.last.statis_title if !Kpi.find(title[0]).conditions.empty?
      row["kpi描述"] = Kpi.kpi_type_config_for_value(title[1])[:remarks]
      row["kpi描述"] = Kpi.kpi_type_config_for_value(Kpi.find(title[0]).conditions.last.kpi_type)[:remarks] if !Kpi.find(title[0]).conditions.empty?

      if !arr.map(&:keys).include?([title[1], "kpi描述"])
        arr << row
      end
    }
    arr.append({"member_id": "成员id"})

    if !self.users.empty?
      arr
    else
      []
    end
  end

  def statis_kpi_data(year)
    arr = []
    self.users.joins(:kpi_group).map {|user|
      row = {}

      new_row = {"member_name": user.name}.merge(row)
      user.kpi_group.kpis.where("extract(year from kpis.created_at)  = ?", year).map {|kpi|
        kpi_types(year).pluck(:kpi_type).uniq.map{|type|
          if kpi.kpi_type == type
            # 如果kpi配置存有条件
            conditions = kpi.conditions.map{|e| " #{e.relation} #{Kpi.kpi_type_config_for_value(e.kpi_type)[:action]}#{Kpi.kpi_type_op_for_value(e.kpi_type).call(user.id, e.coverage, year)}#{Kpi.kpi_type_config_for_value(e.kpi_type)[:unit]}/#{e.value}#{Kpi.kpi_type_config_for_value(e.kpi_type)[:unit]}"}.join(" ") unless kpi.conditions.empty?

            new_row["#{type}"] = "不在系统中统计"

            new_row["#{type}"] = "#{Kpi.kpi_type_config_for_value(kpi.kpi_type)[:action]}#{Kpi.kpi_type_op_for_value(type).call(user.id, kpi.coverage, year)}#{Kpi.kpi_type_config_for_value(kpi.kpi_type)[:unit]}/#{kpi.value}#{Kpi.kpi_type_config_for_value(kpi.kpi_type)[:unit]}#{conditions}" if Kpi.kpi_type_config_for_value(kpi.kpi_type)[:is_system]
          end
        }
      }
      new_row = new_row.merge({"member_id": user.id})

      arr << new_row
    }
    arr
  end

  def kpi_types(year)
    self.users.map(&:kpi_group).compact.map{|e| e.kpis.where("extract(year from kpis.created_at)  = ?", year).where(parent_id: nil)}.flatten
  end
end
