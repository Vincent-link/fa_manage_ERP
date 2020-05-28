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

      state_config :status, config: {
          reviewing:    { value: 0, desc: "Reviewing"  },
          interesting:  { value: 1, desc: "Interesting"},
          voting:       { value: 2, desc: "Voting"     },
          pursue:       { value: 3, desc: "Pursue"     },
          execution:    { value: 4, desc: "Execution"  },
          closing:      { value: 5, desc: "Closing"    },
          closed:       { value: 6, desc: "Closed"     },
          paid:         { value: 7, desc: "Paid"       },
          hold:         { value: 8, desc: "Hold"       },
          pass:         { value: 9, desc: "Pass"       }
      }
    end
  end
end
