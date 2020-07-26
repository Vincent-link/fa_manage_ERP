class PipelineDivide < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :pipeline
  belongs_to :user
  belongs_to :team

  delegate :name, to: :team, prefix: true, allow_nil: true
  delegate :name, to: :user, prefix: true

  after_commit :reindex_pipeline

  def is_fa_bu?
    bu_id == Settings.fa_team_id
  end

  # 给定日期最后修改后的信息
  def version_pipeline_divide(date = nil)
    return self if date.nil? || date.end_of_month == Date.current.end_of_month
    version = versions.select { |v| v.created_at.end_of_month.to_date <= date }.last
    return nil if version.blank? || version.event == 'destroy'
    next_version = versions.select { |v| v.id > version&.id }.first
    next_version.present? ? next_version.reify : self
  end

  private

  def reindex_pipeline
    pipeline.reindex
  end
end
