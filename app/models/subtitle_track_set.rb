class SubtitleTrackSet < ActiveRecord::Base
  belongs_to :video
  has_many :subtitle_track
  def get_video_id
    return self.video_id
  end
end
