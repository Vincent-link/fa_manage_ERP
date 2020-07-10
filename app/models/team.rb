class Team < DefaultTeam
  has_many :users
  has_many :kpi_groups

  has_many :sub_teams, class_name: "Team", foreign_key: :parent_id

  def statis_kpi_titles(year)
    arr = []
    titles = kpi_types(year)

    arr.unshift({"member_name": "成员名称"})
    titles.pluck(:kpi_type, :desc).uniq.map { |title|
      row = {}
      row[title[0]] = Kpi.kpi_type_desc_for_value(title[0])
      row["kpi描述"] = title[1]
      arr << row
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
          # 如果kpi配置存有条件
          if kpi.kpi_type == type
            conditions = kpi.conditions.map{|e| " #{e.relation} #{Kpi.kpi_type_op_for_value(e.kpi_type).call(user.id, e.coverage)}/#{e.value}"}.join(" ") unless kpi.conditions.empty?
            new_row["#{type}"] = "#{Kpi.kpi_type_op_for_value(type).call(user.id, kpi.coverage)}/#{kpi.value}#{conditions}"
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
