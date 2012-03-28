class Video < ActiveRecord::Base
  @sub_percent = nil
  has_many :subtitle_track_set

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
    Subtitle.all
            .find_all{|st| (st.updated_at > (Time.current() - 1800))}
            .collect{|st| st.subtitle_track.get_video_id()}
            .uniq()
            .take(num)
            .collect{|i| Video.find(i)}
  end

  def sub_percent
    return @sub_percent unless @sub_percent.nil?
    cur_start = 0
    cur_end = 0
    covered = 0
    Subtitle.all
            .find_all{|st| (st.subtitle_track.get_video_id() == self.id)}
            .sort{|a,b| a.start_time <=> b.start_time}.each do |sub|
      if sub.start_time > cur_end + 0.3
        covered += cur_end - cur_start
        cur_start = sub.start_time
        cur_end = sub.end_time || sub.start_time
      elsif !sub.end_time.nil?
        cur_end = [cur_end, sub.end_time].max
      end
    end
    return @sub_percent = 100 * (covered + (cur_end - cur_start)) / duration
  end
end
