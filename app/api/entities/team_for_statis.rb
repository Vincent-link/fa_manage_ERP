module Entities
  class TeamForStatis < Base
    present_collection true, :companies

    expose :companies, using: Entities::TeamForStatis
    expose :avg

    private

    def avg
      options[:avg]
    end
  end
end
