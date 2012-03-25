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
        # Find the title from the YouTube api
        api_uri = URI.parse('http://gdata.youtube.com/feeds/api/videos/' + yt_id)
        api_uri.query = "alt=json&fields=title"
        resp = Net::HTTP.get(api_uri)
        json = JSON.parse(resp)
        @video = Video.new do |v|
          v.yt_url = yt_id
          v.title = json["entry"]["title"]["$t"]
        end
      end
    else
      @video = Video.new do |v|
        v.title = params[:title]
        v.url = params[:url]
      end
    end
    @video.save()
    redirect_to "/videos/" + @video.id.to_s()
  end

  def show
    @video = Video.find(params[:id])
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
