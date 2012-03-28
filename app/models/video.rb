class Video < ActiveRecord::Base
  @sub_percent = nil
  has_many :subtitle

  validate :has_url
  before_validation :generate_uuid

  def has_url
    if url.nil? && yt_url.nil?
      errors.add(:url, "must specify url or YouTube url")
    end
  end

  def generate_uuid
    if not self.uuid
      self.uuid = UUIDTools::UUID.random_create.to_s
    end
  end

  def self.get_unsubbed(num)
    return Video.all()
                .find_all{|v| v.sub_percent < 50}
                .sort_by{rand}
                .take(num)
  end

  def self.get_active(num)
    return Video.select(:video_id)
                .joins(:subtitle)
                .where("subtitles.updated_at > ?", Time.current() - 1800)
                .group(:video_id)
                .limit(num).collect{|v| Video.find(v.video_id)}
  end

  def sub_percent
    if !@sub_percent.nil?
      return @sub_percent
    end
    cur_start = 0
    cur_end = 0
    covered = 0
    Subtitle.where(:video_id => id).order(:start_time).each do |sub|
      if sub.start_time > cur_end
        covered += cur_end - cur_start
        cur_start = sub.start_time
        cur_end = sub.end_time
      else
        cur_end = max(cur_end, sub.end_time)
      end
    end
    return @sub_percent = 100 * (covered + (cur_end - cur_start)) / duration
  end
end
