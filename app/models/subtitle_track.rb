class SubtitleTrack < ActiveRecord::Base
  belongs_to :subtitle_track_set
  has_many :subtitle
  def get_video_id
    return subtitle_track_set.get_video_id()
  end
end
