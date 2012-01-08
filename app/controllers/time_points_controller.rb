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
      tp.time_point_type = ('true' == params[:time_point_type])
      tp.voice = voice
    end

    status = 200
    time_points =
      TimePoint.where(:video_id => params[:video_id], :voice => voice)
               .order('time')
    prev = -1
    for pt in time_points
      if pt.time == time
        status = 400
      end
      if pt.time_point_type == 0
        prev = pt.time.to_f
      elsif time >= prev && time <= pt.time.to_f
        status = 400
      end
    end
    
    if params[:time_point_type] == "true"
      # find the immediately preceding time point of this voice
      prec = time_points.find_all{|pt| pt.time.to_f < time && pt.voice == voice.to_i}
      y prec
      if prec.length == 0 || prec.last.time_point_type == 1
        status = 400
      end
    end

    if status == 200
      @time_point.save()
      data = {:type => 'create_time_point', :value => @time_point}
      Juggernaut.publish("channel1", data)
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
