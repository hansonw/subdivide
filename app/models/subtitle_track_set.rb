class SubtitleTrackSet < ActiveRecord::Base
  belongs_to :video
  has_many :subtitle_track
end
