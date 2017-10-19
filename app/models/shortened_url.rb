class ShortenedUrl < ApplicationRecord
  validates :short_url, presence: true, uniqueness: true
  validates :user_id, :long_url, presence: true

  belongs_to :submitter,
    class_name: 'User',
    primary_key: :id,
    foreign_key: :user_id

  has_many :visits,
    class_name: 'Visit',
    primary_key: :id,
    foreign_key: :shortened_url_id

  has_many :visitors,
    -> { distinct },
    through: :visits,
    source: :user

  def self.random_code
    code = SecureRandom.urlsafe_base64
    until !ShortenedUrl.exists?(short_url: code)
      code = SecureRandom.urlsafe_base64
    end

    code
  end

  def self.assign_url(user, long_url)
    ShortenedUrl.create!(long_url: long_url,
      short_url: ShortenedUrl.random_code, user_id: user.id)
  end

  def num_clicks
    self.visits.count
  end

  def num_uniques
    self.visitors.count
  end

  def num_recent_uniques
    self.visits.select('user_id')
    .where('created_at < ?' , 10.minutes.ago)
    .distinct
  end

end
