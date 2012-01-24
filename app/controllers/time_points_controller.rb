class TimePointsController < ApplicationController
  def index
    @timepoints = Video.find(params[:video_id]).time_point
    respond_to do |format|
      format.html # index.html.slim
      format.xml  { render :xml => @timepoints }
      format.json { render :json => @timepoints }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.slim
    end
  end

  def edit
    respond_to do |format|
      format.html # edit.html.slim
    end
  end

  def create
    time = params[:time].to_f
    voice = params[:voice].to_i
    @time_point = TimePoint.new do |tp|
      tp.video_id = params[:video_id]
      tp.time = time
      tp.time_point_type = params[:time_point_type].to_i
      tp.voice = voice
    end

    status = 200

    if @time_point.save()
      data = {:type => 'create_time_point', :value => @time_point}
      Juggernaut.publish(@time_point.video.uuid, data)
    else
      status = 400
    end
    respond_to do |format|
      format.xml  { render :xml => @time_point }
      format.json { render :json => @time_point, :status => status }
    end
  end

  def show
    @time_point = TimePoint.find(params[:id])
    @time_point.sort! { |a,b| a.time.to_f <=> b.time.to_f }
    respond_to do |format|
      format.html # show.html.slim
      format.xml  { render :xml => @time_point }
      format.json { render :json => @time_point }
    end
  end

  def update
    @time_point = TimePoint.find(params[:id])
    @time_point.time = params[:time]
    @time_point.time_point_type = params[:time_point_type].to_i
    @time_point.voice = params[:voice]

    end_point = nil
    if params[:end] != "null"
      end_point = TimePoint.find(params[:end][:id])
      end_point.time = params[:end][:time]
      # can't figure out how to put this in the validator..
      between = TimePoint
        .where(['cast(time as double precision) >= ?', @time_point.time.to_f])
        .where(['cast(time as double precision) <= ?', end_point.time.to_f])
        .where(['id not in (?, ?)', @time_point.id, end_point.id])
        .count
      before = TimePoint
        .where(['cast(time as double precision) <= ?', @time_point.time.to_f])
        .where(['id != ?', @time_point.id])
        .order('cast(time as double precision)')
        .last
      if between == 0 && (before.nil? || before.time_point_type == 1)
        success = @time_point.save(:validate => false) &&
                  end_point.save(:validate => false)
      else
        success = false
      end
    else
      success = @time_point.save()
    end
    if success
      status = 200
      data = {:type => 'update_time_point', :value => @time_point}
      Juggernaut.publish(@time_point.video.uuid, data)
      if end_point.nil? == false
        data = {:type => 'update_time_point', :value => end_point}
        Juggernaut.publish(@time_point.video.uuid, data)
      end
    else
      status = 400
      data = {:type => 'update_time_point',
              :value => TimePoint.find(params[:id])}
      Juggernaut.publish(@time_point.video.uuid, data)
      if end_point.nil? == false
        data = {:type => 'update_time_point',
                :value => TimePoint.find(params[:end][:id])}
        Juggernaut.publish(@time_point.video.uuid, data)
      end
    end
    respond_to do |format|
      format.xml  { render :xml => @time_point }
      format.json { render :json => @time_point, :status => status }
    end
  end

  def destroy
    @time_point = TimePoint.find(params[:id])
    if @time_point.nil? == false
      TimePoint.destroy(params[:id])
      data = {:type => 'delete_time_point', :value => params[:id]}
      Juggernaut.publish(@time_point.video.uuid, data)
    end
    @response = [:destroy => 'destroy']
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end
end
