class TimePoint < ActiveRecord::Base
  belongs_to :video
  has_many :subtitle

  validates :time, :presence => true
  validate :end_must_follow_start, :end_must_not_preceed_end

  def end_must_follow_start
    if time_point_type == 1
      prev_tp = TimePoint.where(['cast(time as double precision) <= ?', time.to_f])
                         .where(id.nil? ? ['id != ?', id] : '1 = 1')
                         .last(:conditions => {:voice => voice, :video_id => video_id})
      if (prev_tp.nil?) && (prev_tp.time_point_type == 1)
        errors.add(:time_point_type,'end point cannot be inserted after an end point')
      end
    end
  end

  def end_must_not_preceed_end
    if time_point_type == 1
      next_tp = TimePoint.where(['cast(time as double precision) >= ?', time.to_f])
                         .where(id.nil? ? ['id != ?', id] : '1 = 1')
                         .first(:conditions => {:voice => voice, :video_id => video_id})
      if (next_tp.nil?) && (next_tp.time_point_type == 1)
        errors.add(:time_point_type,'end point cannot be inserted before an end point')
      end
    end
  end
end
