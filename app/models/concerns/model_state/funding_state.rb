module ModelState
  module FundingState
    extend ActiveSupport::Concern
    include StateConfig

    included do
      state_config :category, config: {
          pp:       {value: 1, desc: 'PP', code: [:category, :company_id, :round_id, :target_amount_currency, :target_amount,
                                                  :share, :shiny_word, :com_desc, :products_and_business, :financial,
                                                  :operational, :market_competition, :financing_plan, :source_type,
                                                  :source_member, :source_detail, :funding_score, :normal_user_ids]},
          ma:       {value: 2, desc: 'M&A', code: [:category, :company_id, :round_id, :target_amount_currency, :target_amount,
                                                   :share, :shiny_word, :com_desc, :products_and_business, :financial,
                                                   :operational, :market_competition, :financing_plan, :source_type,
                                                   :source_member, :source_detail, :funding_score, :normal_user_ids]},
          advisory: {value: 3, desc: '咨询', code: [:category, :normal_user_ids]}
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

      state_config :source_type, config: {
          member_referral:         { value: 0, desc: "投资人推荐"   },
          member_recommend:        { value: 1, desc: "找投资人引荐" },
          find_company:            { value: 2, desc: "自己找公司"   },
          company_find:            { value: 3, desc: "公司找到我"   },
          colleague_introduction:  { value: 4, desc: "同事介绍"    },
          company_email:           { value: 5, desc: "公司对外邮箱" },
          company_edition:         { value: 6, desc: "公司版"      }
      }

      state_config :bsc_status, config: {
          started:      { value: "started",  desc: "bsc已启动"     },
          evaluatting:  { value: "evaluatting", desc: "bsc投票中"  },
          finished:     { value: "finished",  desc: "bsc完成"      }
      }

      state_config :confidentiality_level, config: {
          first: {value: 1, desc: '假数据level 1'}
      }

      state_config :all_funding_file_type, config: {
          bp:     {value: 'file_bp',     desc: 'BP'},
          nda:    {value: 'file_nda',    desc: 'NDA'},
          teaser: {value: 'file_teaser', desc: 'Teaser'},
          model:  {value: 'file_model',  desc: 'MODEL'},
          el:     {value: 'file_el',     desc: 'EL'},
          ts:     {value: 'file_ts',     desc: 'TS'},
          spa:    {value: 'file_spa',    desc: 'SPA'},
      }
    end
  end
end
