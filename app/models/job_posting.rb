class JobPosting < ApplicationRecord
  include Markdownable
  include FriendlyId

  default_scope { order('created_at DESC') }

  validates :title, presence: true
  validates :organisation, presence: true
  validates :description_markdown, presence: true
  validates :country, presence: true
  validates :posting_date, presence: true

  friendly_id :title, use: [:slugged]
  as_enum :status, [:draft, :open, :closed], map: :string

  def country_name
    c = ISO3166::Country[country]
    c.translations[I18n.locale.to_s] || c.name
  end

  def record_page_view
    self.page_views ||= 0
    self.page_views  += 1
    save
  end
end
