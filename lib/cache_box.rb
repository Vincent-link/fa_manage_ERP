class CacheBox
  def self.dm_sector_tree
    Rails.cache.fetch('dm_sector_tree') do
      Zombie::DmSector.sector_tree.as_json
    end
  end

  def self.dm_root_sector
    Rails.cache.fetch('dm_root_sector') do
      Zombie::DmSector.root_sectors.as_json
    end
  end

  def self.dm_single_sector_tree
    Rails.cache.fetch('dm_single_sector_tree') do
      Zombie::DmSector.root_sectors.as_json.map {|ins| [ins['id'], ins['name']]}.to_h
    end
  end

  def self.dm_rounds
    Rails.cache.fetch('dm_rounds') do
      Zombie::DmInvestRound.all.as_json.map do |ins|
        ins['available'] = true
        ins
      end
    end
  end

  def self.dm_single_rounds
    Rails.cache.fetch('dm_single_rounds') do
      Zombie::DmInvestRound.all.map {|ins| [ins.id, ins.name]}.to_h
    end
  end

  def self.dm_currencies
    Rails.cache.fetch('dm_currencies') do
      Zombie::DmCurrency.all.as_json.map do |ins|
        ins['available'] = [1, 3].include?(ins['id'])
        ins
      end
    end
  end

  def self.dm_location_tree
    Rails.cache.fetch('dm_location_tree') do
      Zombie::DmLocation.location_tree.map do |ins|
        ins.id = 0 - ins.id
        ins
      end
    end
  end

  def self.dm_member_location
    Rails.cache.fetch('dm_location_tree') do
      Zombie::DmLocation.where(name: ['北京', '上海', '天津', '重庆', '香港', '南京', '苏州', '杭州', '宁波', '厦门', '武汉', '长沙', '广州', '深圳', '成都', '西安']).select(:id, :name).as_json
    end
  end

  def self.dm_locations
    Rails.cache.fetch('dm_locations') do
      Zombie::DmLocation.all._select(:id, :name, :parent_id).index_by(&:id)
    end
  end

  def self.dm_position_ranks
    Rails.cache.fetch('dm_position_ranks') do
      Zombie::DmPositionRank.all.select(:id, :name, :en_name).as_json
    end
  end

  def self.get_group_user_ids(id)
    return [] if id.blank?
    Rails.cache.fetch("cb_get_group_user_ids_#{id}") do
      ids = User.where(leader_id: id).pluck(:id)
      [id] | ids.map {|i| CacheBox.get_group_user_ids(i)}.flatten
    end
  end

  def self.user_cache
    Rails.cache.fetch("user_cache", expires_in: 1.minutes) do
      User.pluck(:id, :name).to_h
    end
  end
end