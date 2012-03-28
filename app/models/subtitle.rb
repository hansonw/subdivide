class Subtitle < ActiveRecord::Base
  belongs_to :subtitle_track

  validate :start_time, :presence => true
  validate :end_must_follow_start, :no_overlaps

  def end_must_follow_start
    if !end_time.nil? && end_time < start_time
      errors.add(:end_time, 'end time must be after start_time')
    end
  end

  def no_overlaps
    prev_sub = Subtitle.where('start_time <= ?', start_time)
                       .where(id.nil? ? '1=1' : ['id != ?', id])
                       .where(:subtitle_track_id => subtitle_track_id)
                       .where(:voice => voice)
                       .order(:start_time)
                       .last()
    next_sub = Subtitle.where('start_time >= ?', start_time)
                       .where(id.nil? ? '1=1' : ['id != ?', id])
                       .where(:subtitle_track_id => subtitle_track_id)
                       .where(:voice => voice)
                       .order(:start_time)
                       .first()
    if !prev_sub.nil? && (prev_sub.start_time == start_time ||
                          !prev_sub.end_time.nil? && prev_sub.end_time >= start_time) ||
       !next_sub.nil? && (next_sub.start_time == start_time ||
                          !end_time.nil? && next_sub.start_time <= end_time)
      errors.add(:start_time, 'subtitle must not overlap other subtitle')
    end
  end

  def get_video_id
    return subtitle_track.get_video_id()
  end
end
