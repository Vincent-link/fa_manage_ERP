class Email < ApplicationRecord
  acts_as_paranoid

  has_many_attached :email_extras

  belongs_to :emailable, polymorphic: true
  belongs_to :user
  belongs_to :from, class_name: 'User', foreign_key: :from_id, optional: true
  has_many :email_blobs
  has_many :blobs, through: :email_blobs, class_name: 'ActiveStorage::Blob'
  has_many :email_receivers
  has_many :email_to_groups
  has_many :email_tos, through: :email_to_groups
  has_many :cc_relations, -> {kind_cc}, class_name: 'EmailReceiver'
  has_many :bcc_relations, -> {kind_bcc}, class_name: 'EmailReceiver'

  has_many :cc_users, through: :cc_relations, source: :receiverable, source_type: 'User'
  has_many :bcc_users, through: :bcc_relations, source: :receiverable, source_type: 'User'

  has_many :receiver_members, through: :email_receivers, source: :receiverable, source_type: 'Member'
  has_many :cc_members, through: :cc_relations, source: :receiverable, source_type: 'Member'
  has_many :bcc_members, through: :bcc_relations, source: :receiverable, source_type: 'Member'
  has_one :verification, as: :verifyable



  before_create :gen_status

  include StateConfig
  include Watermark

  state_config :status, config: {
      not_push:     { value: 1, desc: "未推送"  },
      success:      { value: 2, desc: "推送成功"},
      fail:         { value: 3, desc: "推送失败"},
      pushing:      { value: 4, desc: "推送中"},
      incomplete:   { value: 5, desc: "部分推送失败"},
  }

  state_config :email_template, config: {
      funding:  { value: 1,
                  desc: "项目推送",
                  title: -> (emailable){ "华兴资本推荐：#{emailable.name}" },
                  description: -> (emailable){ "<p>您好，</p><p>我们正在帮助#{emailable.name}进行#{CacheBox.dm_single_rounds[emailable.round_id]}融资，附件中是#{emailable.name}项目的情况介绍，供您参考，如有兴趣欢迎反馈。</p><p></p><p>【公司简介】</p><p>#{emailable.com_desc}</p><p></p><p>【产品与商业模式】</p><p>#{emailable.products_and_business}</p><p></p><p>【财务数据】</p><p>#{emailable.financial}</p><p></p><p>【运营数据】</p><p>#{emailable.operational}</p><p></p><p>【市场与竞争分析】</p><p>#{emailable.market_competition}</p><p></p><p>【融资计划】</p><p>#{emailable.financing_plan}</p><p></p><p>#{emailable.name}本轮拟融资#{emailable.target_amount}万#{CacheBox.dm_currencies.map {|ins| [ins['id'], ins['name']]}.to_h[emailable.target_amount_currency]}，主要用于市场扩张及售后服务体系的完善。如您对于#{emailable.name}有任何问题或相关需求，欢迎随时与我们联系。谢谢！</p>"},
                  greeting: -> (emailable) { 'Dear' },
                  file_prefix: ''}
  }

  state_config :signature_template, config: {
      cr_default:  { value: 1,
                     desc: '华兴默认签名',
                     signature: ->(from) { "<p>Best Regards,</p><p> </p><p>#{from.name}</p>#{from.user_title.present? ? "<p>#{from.user_title&.name}</p>" : ''}<p>华兴资本 | China Renaissance</p><p>手机：#{from.mobile} | 微信：#{from.wechat}</p>" }}
  }

  state_config :emailable_type, config: {
      funding: { value: 'Funding',
                 desc: '项目',
                 email_template: Email.email_template_filter(:funding),
                 use_template: true}
  }

  def gen_status
    self.status = Email.status_not_push_value
  end

  def change_receiver(params)
    self.change_to(params)
    self.change_cc(params)
  end

  def change_to(params)
    case self.emailable_type
    when 'Funding'
      params[:tos].group_by{|ins| ins[:type]}.each do |k, v|
        email_to_groups = self.email_to_groups
        if k == 'member'
          Member.where(id: v.map{|ins| ins[:id]}).group_by{|ins| ins.organization_id}.each do |m_k, m_v|
            email_to_group = email_to_groups.find_or_create_by(organization_id: m_k)
            email_to_group.member_ids = m_v.map(&:id)
          end
        end
      end
    end
  end

  def change_cc(params)
    (params[:ccs] || []).group_by{|ins| ins[:type]}.each do |k, v|
      if k.nil?
        v.each{|ins| self.cc_relations.find_or_create_by(email: ins)}
      else
        self.try("cc_#{k}_ids=", v.pluck(:id).uniq)
      end
    end
  end

  def change_blob(params)
    blob_ids = params[:files].map{|ins| ins[:blob_id]}.compact.uniq
    relation_blob_ids = ActiveStorage::Attachment.where(blob_id: params[:files].map{|ins| ins[:blob_id]}.compact.uniq).map(&:blob_id)
    (blob_ids - relation_blob_ids).each do |blob_id|
      ActiveStorage::Attachment.create!(blob_id: blob_id, name: 'email_extras', record_type: "Email", record_id: self.id)
    end
    params[:files].each do |ins|
      self.email_blobs.find_or_create_by(ins.slice(:blob_id, :file_kind))
    end
  end

  def receiver_organizations
    Organization.where(id: self.receiver_members.map(&:organization_id))
  end

  def gen_verification
    raise '不能重复提交审核' if self.verification.present?
    emailable = self.emailable
    verification_type = Verification.try("verification_type_#{self.emailable_type.underscore}_email_value")
    desc = Verification.verification_type_config["#{self.emailable_type.underscore}_email".to_sym][:desc].call(emailable.name)
    if self.from_id.present?
      self.verification.create(verification_type: verification_type, desc: desc, user_id: params[:from_id], sponor: params[:user_id])
    else
      raise '发件人是自己不需要审核'
    end
  end

  def auth_test_user(params)
    if self.emailable_type == 'Funding'
      other_ids = params[:user_ids] - self.emailable.funding_users.map(&:user_id)
      others = User.where(id: other_ids)
      raise "#{others.map(&:name).join('、')}不是项目成员" if others.present?
    end
  end

  def get_options(user, subject = "", dear_to = "", to = nil, cc = nil, bcc = nil)
    {:to => to,
     :dear_to => dear_to,
     :cc => cc,
     :bcc => bcc,
     :user => user.valid_email_password? ? user : nil,
     :subject => subject,
    }
  end

  def test_push_email(params)
    to_users = User.where(id: params[:user_ids])
    to = to_users.map(&:email).compact
    user = User.current
    self.email_to_groups.each do |email_to_group|
      dear_to = email_to_group.dear_to
      options = self.get_options(user, "#{self.title}测试推送", dear_to, to)
      mark_string = email_to_group.real_to
      send_email = EmailPushMailer.send_email_push(options, self, mark_string)
      puts "---------------#{send_email}---------------"
    end
  end

  def official_push_email
    raise '邮件推送中不要重复推送' if self.status_pushing?
    raise '邮件推送成功不要重复推送' if self.status_success?
    self.email_to_groups.where(status: EmailToGroup.status_filter(:not_push, :fail)).update_all(status: EmailToGroup.status_pushing_value)
    self.update(:status => Email.status_pushing_value, :send_at => Time.now)
    self.email_to_groups.status_pushing.each do |email_to_group|
      dear_to = email_to_group.dear_to
      to = email_to_group.email_tos.includes(:toable).map{|ins| ins.toable&.email}.compact
      user = User.current
      mark_string = email_to_group.real_to
      options = self.get_options(user, "#{self.title}", dear_to, to, self.cc_users.map(&:email).compact)
      OfficialPushEmailJob.perform_later(options, self, email_to_group.id, mark_string)
    end
  end
end