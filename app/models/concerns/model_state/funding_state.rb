module ModelState
  module FundingState
    extend ActiveSupport::Concern
    include StateConfig

    included do
      state_config :categroy, config: {
          pp:       {value: 1, desc: 'PP', code: [:category, :company_id, :round_id, :currency_id, :target_amount_min,
                                                  :shares_min, :shiny_word, :com_desc, :products_and_business, :financial,
                                                  :operational, :market_competition, :financing_plan, :sources_type,
                                                  :sources_member, :sources_detail, :funding_score, :project_user_ids]},
          ma:       {value: 2, desc: 'M&A', code: [:category, :company_id, :round_id, :currency_id, :target_amount_min,
                                                   :shares_min, :shiny_word, :com_desc, :products_and_business, :financial,
                                                   :operational, :market_competition, :financing_plan, :sources_type,
                                                   :sources_member, :sources_detail, :funding_score, :project_user_ids]},
          advisory: {value: 3, desc: '咨询', code: [:category, :project_user_ids]}
      }
    end
  end
end
