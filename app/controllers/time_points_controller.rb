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
    if @time_point.save()
      data = {:type => 'update_time_point', :value => @time_point}
    else
      data = {:type => 'update_time_point',
              :value => TimePoint.find(params[:id])}
    end
    Juggernaut.publish(@time_point.video.uuid, data)
    respond_to do |format|
      format.xml  { render :xml => @time_point }
      format.json { render :json => @time_point }
    end
  end

  def destroy
    TimePoint.destroy(params[:id])
    @response = [:destroy => 'destroy']
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end
end
