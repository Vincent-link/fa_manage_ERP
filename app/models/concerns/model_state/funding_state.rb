module ModelState
  module FundingState
    extend ActiveSupport::Concern
    include StateConfig

    included do
      state_config :category, config: {
          pp:       {value: 1, desc: 'PP', code: [:category, :company_id, :round_id, :target_amount_currency, :target_amount,
                                                  :share, :shiny_word, :com_desc, :products_and_business, :source_type,
                                                  :funding_score, :normal_user_ids]},
          ma:       {value: 2, desc: 'M&A', code: [:category, :company_id, :round_id, :target_amount_currency, :target_amount,
                                                   :share, :shiny_word, :com_desc, :products_and_business, :source_type,
                                                   :funding_score, :normal_user_ids]},
          advisory: {value: 3, desc: '其他', code: [:category, :normal_user_ids]}
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
          initial:      { value: nil,   desc: "Initial",     zh_desc: "未启动bsc" },
          started:      { value: 1,     desc: "Started",     zh_desc: "bsc已启动" },
          evaluatting:  { value: 2,     desc: "Evaluatting", zh_desc: "进行中"    },
          finished:     { value: 3,     desc: "Finished",    zh_desc: "已完成"    }
      }

      state_config :confidentiality_level, config: {
          first: {value: 1, desc: '假数据level 1'}
      }

      state_config :all_funding_file_type, config: {
          bp:        {value: 1, desc: 'BP',     file: 'file_bp',        },
          nda:       {value: 2, desc: 'NDA',    file: 'file_nda',       },
          teaser:    {value: 3, desc: 'Teaser', file: 'file_teaser',    },
          model:     {value: 4, desc: 'MODEL',  file: 'file_model',     },
          materials: {value: 5, desc: '其他',    file: 'file_materials', },
          el:        {value: 6, desc: 'EL',     file: 'file_el',        },
          ts:        {value: 7, desc: 'TS',     file: 'file_ts',        },
          spa:       {value: 8, desc: 'SPA',    file: 'file_spa',       },
      }

      state_config :other_funding_type, config: {
          ibd: {value: 1, desc: 'IBD', model: 'Zombie::AbFunding'},
          hc:  {value: 2, desc: 'HC',  model: 'Zombie::HcFunding' }
      }

      state_config :type_range, config: {
          ka:        {value: 1, desc: '只看KA项目' },
          my_team:   {value: 2, desc: '只看本组项目'},
          system:    {value: 3, desc: '只看FA项目' },
          other:     {value: 4, desc: '只看外部项目'}
      }
    end
  end
end
