class FundingCompanyContact < ApplicationRecord
  acts_as_paranoid

  include StateConfig

  belongs_to :funding

  state_config :position_id, config: {
      ceo: {value: 1,  desc: 'CEO'},
      cto: {value: 2,  desc: 'CTO'},
      coo: {value: 3,  desc: 'COO'},
      cmo: {value: 4,  desc: 'CMO'},
      cfo: {value: 5,  desc: 'CFO'},
      cco: {value: 6,  desc: 'CCO'},
      cpo: {value: 7,  desc: 'CPO'},
      cso: {value: 8,  desc: 'CSO'},
      cxo: {value: 9,  desc: 'CXO'},
      cio: {value: 10, desc: 'CIO'},
      cro: {value: 11, desc: 'CRO'},
      cbo: {value: 12, desc: 'CBO'},
      cqo: {value: 13, desc: 'CQO'},
      cdo: {value: 14, desc: 'CDO'},
      cho: {value: 15, desc: 'CHO'},
      president: {value: 16, desc: 'PRESIDENT'}
  }

  def position_desc
    self.position_id_desc
  end
end
