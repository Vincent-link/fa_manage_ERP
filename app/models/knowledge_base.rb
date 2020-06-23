class KnowledgeBase < ApplicationRecord
  has_many_attached :files

  belongs_to :parent, :class_name => 'KnowledgeBase', optional: true
  has_many :children, :class_name => 'KnowledgeBase', foreign_key: :parent_id, dependent: :destroy

  include StateConfig

  state_config :knowledge_base_type, config: {
    research_report:{value: 1, desc: "research_report"},
    sector_report:  {value: 2, desc: "sector_report"}
  }

  def user_name
    User.find(self.user_id).name
  end
end
