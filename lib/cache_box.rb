class CacheBox
  def self.dm_sector_tree
    Rails.cache.fetch('dm_sector_tree') do
      Zombie::DmSector.root_sectors.as_json
    end
  end

  def self.dm_rounds
    Rails.cache.fetch('dm_rounds') do
      Zombie::DmInvestRound.all.as_json
    end
  end

  def self.dm_currencies
    Rails.cache.fetch('dm_currencies') do
      Zombie::DmCurrency.all.as_json
    end
  end

  def self.dm_locations
    Rails.cache.fetch('dm_locations') do
      Zombie::DmLocation.location_tree
    end
  end
end