class CacheBox
  def self.dm_sector_tree
    Rails.cache.fetch('dm_sector_tree') do
      Zombie::DmSector.root_sectors.as_json
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

  def self.dm_currencies
    Rails.cache.fetch('dm_currencies') do
      Zombie::DmCurrency.all.as_json.map do |ins|
        ins['available'] = [1, 3].include?(ins['id'])
        ins
      end
    end
  end

  def self.dm_locations
    Rails.cache.fetch('dm_locations') do
      Zombie::DmLocation.location_tree.map do |ins|
        ins.id = 0 - ins.id
        ins
      end
    end
  end

  def self.dm_position_ranks
    Rails.cache.fetch('dm_position_ranks') do
      Zombie::DmPositionRank.all.select(:id, :name, :en_name).as_json
    end
  end
end