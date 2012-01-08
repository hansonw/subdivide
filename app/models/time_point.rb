class TimePoint < ActiveRecord::Base
  belongs_to :video
  has_many :subtitle

  validates :time, :presence => true
  validate :end_must_follow_start, :end_must_not_preceed_end

  def end_must_follow_start
    if time_point_type == 1
      prev_tp = TimePoint.where(['cast(time as double precision) <= ?', time.to_f])
                         .where(id.nil? ? '1 = 1' : ['id != ?', id])
                         .last(:conditions => {:voice => voice, :video_id => video_id})
      y 'prev'
      y prev_tp
      if (prev_tp.nil? == false) && (prev_tp.time_point_type == 1)
        errors.add(:time_point_type,'end point cannot be inserted after an end point')
      end
    end
  end

  def end_must_not_preceed_end
    if time_point_type == 1
      next_tp = TimePoint.where(['cast(time as double precision) >= ?', time.to_f])
                         .where(id.nil? ? '1 = 1' : ['id != ?', id])
                         .first(:conditions => {:voice => voice, :video_id => video_id})
      y 'next'
      y next_tp
      if (next_tp.nil? == false) && (next_tp.time_point_type == 1)
        errors.add(:time_point_type,'end point cannot be inserted before an end point')
      end
    end
  end
end
