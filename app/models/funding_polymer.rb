class FundingPolymer < ApplicationRecord
  self.table_name = 'fundings'

  acts_as_paranoid
  has_paper_trail
  searchkick language: 'chinese'

  include ModelState::FundingState

  belongs_to :company

  has_many :time_lines, -> {order(created_at: :desc)}, class_name: 'TimeLine', foreign_key: :funding_id

  has_many :funding_normal_users, -> { kind_normal_users }, class_name: 'FundingUser', foreign_key: :funding_id
  has_many :normal_users, through: :funding_normal_users, source: :user

  has_many :funding_bd_leader, -> { kind_bd_leader }, class_name: 'FundingUser', foreign_key: :funding_id
  has_many :bd_leader, through: :funding_bd_leader, source: :user

  has_many :funding_execution_leader, -> { kind_execution_leader }, class_name: 'FundingUser', foreign_key: :funding_id
  has_many :execution_leader, through: :funding_execution_leader, source: :user

  has_many :funding_users, foreign_key: :funding_id
  has_many :funding_all_users, through: :funding_users, source: :user

  has_many :pipelines, foreign_key: :funding_id

  has_many :funding_members, through: :funding_users, source: :user

  has_many :verifications, as: :verifyable

  scope :search_import, -> { includes(:company, :verifications) }

  def search_data
    data = attributes.merge({pipeline_status: self.pipelines.pluck(:status),
                             company_sector_ids: [self.company&.sector_id, self.company&.parent_sector_id].compact,
                             company_sector_names: [CacheBox.dm_single_sector_tree[self.company&.sector_id], CacheBox.dm_single_sector_tree[self.company&.parent_sector_id]].compact.join("、"),
                             company_location_ids: [self.company&.location_province_id, self.company&.location_city_id].compact,
                             # company_name: self.company&.name,
                             funding_user_ids: self.funding_all_user_ids,
                             funding_team_ids: self.funding_all_users.map(&:team_id)})
    self.track_logs.each do |track_log|
      data.merge! "track_log_#{track_log.id}" => track_log.track_log_details.map(&:content).compact.join("/n")
    end
    self.calendars.where.not(summary: nil).each do |calendar|
      data.merge! "call_report_#{calendar.id}" => calendar.summary
    end
    data
  end

  def self.es_search(params)
    fundings = FundingPolymer.all

    where_hash = {}

    params[:type_range] ||= []

    where_hash[:is_ka] = true if params[:type_range].include? FundingPolymer.type_range_ka_value

    where_hash[:funding_team_ids] = User.current.team_id if params[:type_range].include? FundingPolymer.type_range_my_team_value

    where_hash[:type] = 'Funding' if params[:type_range].include? FundingPolymer.type_range_system_value

    where_hash[:type] = {not: 'Funding'} if params[:type_range].include? FundingPolymer.type_range_other_value

    where_hash[:status] = params[:status] if params[:status].present?

    where_hash[:funding_user_ids] = {all: [User.current.id]} if params[:is_me]

    where_hash[:company_location_ids] = {all: params[:location_ids]} if params[:location_ids].present?

    where_hash[:company_sector_ids] = {all: params[:sector_ids]} if params[:sector_ids].present?

    where_hash[:round_id] = params[:round_ids] if params[:round_ids].present?

    #pipeline status
    where_hash[:pipeline_status] = {all: params[:pipeline_status]} if params[:pipeline_status].present?

    # FundingPolymer.search(params[:keyword], where: where_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)

    if params[:keyword]
      fundings.search(params[:keyword], where: where_hash, page: params[:page], per_page: params[:per_page], highlight: DEFAULT_HL_TAG)
    else
      fundings.search(where: where_hash, page: params[:page], per_page: params[:per_page])
    end
  end

  def tf_search_highlights
    unless self.respond_to?(:search_highlights)
      nil
    else
      result_hash = {'CallReport' => [], 'TrackLog' => []}
      self.search_highlights.each do |k, v|
        if k =~ /^track_log_\d/
          result_hash['TrackLog'] << {
              id: k.slice(/\d{1,}/),
              name: v
          }
        elsif k =~ /^call_report_\d/
          result_hash['CallReport'] << {
              id: k.slice(/\d{1,}/),
              name: v
          }
        else
          result_hash[Funding.human_attribute_name(k)] = v
        end
      end
      result_hash.delete_if{|k,v| ['CallReport', 'TrackLog'].include?(k) && v.empty?}
      result_hash
    end
  end

  def self.export(params)
    params[:page], params[:per_page], params[:status] = 1, 100000, FundingPolymer.status_interesting
    fundings = self.es_search(params)
    currency = CacheBox.dm_currencies.map{|ins| [ins['id'], ins['name']]}.to_h
    round = CacheBox.dm_single_rounds

    file_name = "Interesting项目 -#{Time.now.strftime("%Y-%m-%d").to_s}"
    file_path = "#{Rails.root}/public/export/#{file_name + Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + '.xls'}"
    res = [%w(编号 项目名称 一句话介绍 公司简介 所属行业 融资伦次 融资币种 融资额 当前状态 进入当前状态日期 项目成员)]
    index = 0
    fundings.includes(:time_lines, :company => [:sectors]).each do |funding|
      res << [
          index+=1,
          funding.name,
          funding.shiny_word,
          funding.com_desc,
          funding.company&.sectors&.map(&:name)&.join("、"),
          round[funding.round_id],
          currency[funding.target_amount_currency],
          funding.target_amount,
          funding.status_desc,
          funding.time_lines.first.created_at.strftime("%Y-%m-%d").to_s,
          funding.funding_all_users.map(&:name).join('、')
      ]
    end
    book_data = [["sheet1", res]]
    Common::ExcelGenerator.gen(file_path, book_data)
    [file_path, file_name]
  end
end
