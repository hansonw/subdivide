class TimePoint < ActiveRecord::Base
  belongs_to :video
  has_many :subtitle

  validates :time, :presence => true
  validate :end_must_follow_start, :tp_must_not_preceed_end, :unique

  def end_must_follow_start
    if time_point_type == 1
      prev_tp = TimePoint.where(['cast(time as double precision) <= ?', time.to_f])
                         .where(id.nil? ? '1 = 1' : ['id != ?', id])
                         .order('time')
                         .last(:conditions => {:voice => voice, :video_id => video_id})
      y 'prev'
      y prev_tp
      if (prev_tp.nil? == false) && (prev_tp.time_point_type == 1)
        errors.add(:time_point_type,'end point cannot be inserted after an end point')
      end
    end
  end

  def tp_must_not_preceed_end
    next_tp = TimePoint.where(['cast(time as double precision) >= ?', time.to_f])
                       .where(id.nil? ? '1 = 1' : ['id != ?', id])
                       .order('time')
                       .first(:conditions => {:voice => voice, :video_id => video_id})
    y 'next'
    y next_tp
    if (next_tp.nil? == false) && (next_tp.time_point_type == 1)
      errors.add(:time_point_type,'end point cannot be inserted before an end point')
    end
  end

  def unique
    tp = TimePoint.where(['abs(cast(time as double precision) - ?) <= 1e-9', time.to_f])
                  .where(id.nil? ? '1 = 1' : ['id != ?', id])
                  .where(:voice => voice, :video_id => video_id)
    if tp.length() > 0
      errors.add(:time_point_type, 'duplicate time point')
    end
  end
end
