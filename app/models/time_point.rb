class TimePoint < ActiveRecord::Base
  belongs_to :video
  has_many :subtitle

  validates :time, :presence => true
  validate :end_must_follow_start, :tp_must_not_preceed_end, :unique, :on => :create
  validate :cannot_violate_ordering, :on => :update

  def end_must_follow_start
    if time_point_type == 1
      prev_tp = TimePoint.where(['cast(time as double precision) <= ?', time.to_f])
                         .where(id.nil? ? '1 = 1' : ['id != ?', id])
                         .order('cast(time as double precision)')
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
                       .order('cast(time as double precision)')
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

  def cannot_violate_ordering
    cur_time = TimePoint.where(:id => id).first.time.to_f
    next_tp = TimePoint.where(['cast(time as double precision) >= ?', cur_time])
                       .where(:voice => voice, :video_id => video_id)
                       .where(['id != ?', id])
                       .order('time')
                       .first;
    prev_tp = TimePoint.where(['cast(time as double precision) <= ?', cur_time])
                       .where(:voice => voice, :video_id => video_id)
                       .where(['id != ?', id])
                       .order('time')
                       .last;
    if (next_tp.nil? == false && time.to_f >= next_tp.time.to_f) ||
       (prev_tp.nil? == false && time.to_f <= prev_tp.time.to_f)
      errors.add(:time, 'violates time point ordering')
    end
  end
end
