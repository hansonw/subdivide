class SubtitleTracksController < ApplicationController
  # GET /subtitle_tracks
  # GET /subtitle_tracks.json
  def index
    @subtitle_tracks = SubtitleTrack.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subtitle_tracks }
    end
  end

  # GET /subtitle_tracks/1
  # GET /subtitle_tracks/1.json
  def show
    @subtitle_track = SubtitleTrack.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subtitle_track }
    end
  end

  # GET /subtitle_tracks/new
  # GET /subtitle_tracks/new.json
  def new
    @subtitle_track = SubtitleTrack.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subtitle_track }
    end
  end

  # GET /subtitle_tracks/1/edit
  def edit
    @subtitle_track = SubtitleTrack.find(params[:id])
  end

  # POST /subtitle_tracks
  # POST /subtitle_tracks.json
  def create
    @subtitle_track = SubtitleTrack.new(params[:subtitle_track])

    respond_to do |format|
      if @subtitle_track.save
        format.html { redirect_to @subtitle_track, notice: 'Subtitle track was successfully created.' }
        format.json { render json: @subtitle_track, status: :created, location: @subtitle_track }
      else
        format.html { render action: "new" }
        format.json { render json: @subtitle_track.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subtitle_tracks/1
  # PUT /subtitle_tracks/1.json
  def update
    @subtitle_track = SubtitleTrack.find(params[:id])

    respond_to do |format|
      if @subtitle_track.update_attributes(params[:subtitle_track])
        format.html { redirect_to @subtitle_track, notice: 'Subtitle track was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @subtitle_track.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subtitle_tracks/1
  # DELETE /subtitle_tracks/1.json
  def destroy
    @subtitle_track = SubtitleTrack.find(params[:id])
    @subtitle_track.destroy

    respond_to do |format|
      format.html { redirect_to subtitle_tracks_url }
      format.json { head :ok }
    end
  end
end
