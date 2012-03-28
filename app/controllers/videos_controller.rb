class VideosController < ApplicationController
  def index
    @videos = Video.all
    respond_to do |format|
      format.html # index.html.slim
      format.xml  { render :xml => @videos }
      format.json { render :json => @videos }
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
    @video = nil
    if params[:yt_url] != nil
      require 'net/http'
      require 'json'
      yt_id = nil
      # Figure out the video ID
      URI.parse(params[:yt_url]).query.split("&").each do |q|
        if q.index("v=") == 0
          yt_id = q[2..q.length]
          break
        end
      end
      if yt_id.nil? == false
        existing = Video.where(:yt_url => yt_id).first()
        if !existing.nil?
          redirect_to "/videos/" + existing.id.to_s
          return
        end
        # Find the title from the YouTube api
        api_uri = URI.parse('http://gdata.youtube.com/feeds/api/videos/' + yt_id)
        api_uri.query = "alt=json"
        resp = Net::HTTP.get(api_uri)
        json = JSON.parse(resp)
        entry = json["entry"]
        @video = Video.new do |v|
          v.yt_url = yt_id
          v.title = entry["title"]["$t"]
          v.thumbnail = entry["media$group"]["media$thumbnail"][0]["url"]
          v.uploader = entry["author"][0]["name"]["$t"]
          v.desc = entry["content"]["$t"][0..200]
          v.duration = entry["media$group"]["media$content"][0]["duration"]
        end
      end
    else
      @video = Video.new do |v|
        v.title = params[:title]
        v.url = params[:url]
      end
    end
    @video.views = 0
    @video.save()
    redirect_to "/videos/" + @video.id.to_s()
  end

  def show
    @video = Video.find(params[:id])
    if !@video.nil?
      @video_json = @video.to_json
      if @video.views.nil?
        @video.views = 0
      end
      @video.views += 1
      @video.save()
    else
      redirect_to "/error"
    end
    respond_to do |format|
      format.html # show.html.slim
      format.xml  { render :xml => @video }
      format.json { render :json => @video }
    end
  end

  def update
    @video = Video.find(params[:id])
    @video.url = params[:url]
    @video.save()
    respond_to do |format|
      format.xml  { render :xml => @video }
      format.json { render :json => @video }
    end
  end

  def destroy
    Video.destroy(params[:id])
    @response = [:destroy => 'destroy']
    respond_to do |format|
      format.xml  { render :xml => @response }
      format.json { render :json => @response }
    end
  end
end
