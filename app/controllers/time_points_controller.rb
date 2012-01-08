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
    @time_point = TimePoint.new do |tp|
      tp.video_id = params[:video_id]
      tp.time = params[:time]
      tp.time_point_type = ('true' == params[:time_point_type])
      tp.voice = params[:voice]
    end
    @time_point.save()
    Juggernaut.publish("channel1", "time_points: CREATE")
    Juggernaut.publish("channel1", @time_point)
    respond_to do |format|
      format.xml  { render :xml => @time_point }
      format.json { render :json => @time_point }
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
    @time_point.time_point_type = ('true' == params[:time_point_type])
    @time_point.voice = params[:voice]
    @time_point.save()
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
