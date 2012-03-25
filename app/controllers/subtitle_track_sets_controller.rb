class SubtitleTrackSetsController < ApplicationController
  # GET /subtitle_track_sets
  # GET /subtitle_track_sets.json
  def index
    @subtitle_track_sets = SubtitleTrackSet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @subtitle_track_sets }
    end
  end

  # GET /subtitle_track_sets/1
  # GET /subtitle_track_sets/1.json
  def show
    @subtitle_track_set = SubtitleTrackSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subtitle_track_set }
    end
  end

  # GET /subtitle_track_sets/new
  # GET /subtitle_track_sets/new.json
  def new
    @subtitle_track_set = SubtitleTrackSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subtitle_track_set }
    end
  end

  # GET /subtitle_track_sets/1/edit
  def edit
    @subtitle_track_set = SubtitleTrackSet.find(params[:id])
  end

  # POST /subtitle_track_sets
  # POST /subtitle_track_sets.json
  def create
    @subtitle_track_set = SubtitleTrackSet.new(params[:subtitle_track_set])

    respond_to do |format|
      if @subtitle_track_set.save
        format.html { redirect_to @subtitle_track_set, notice: 'Subtitle track set was successfully created.' }
        format.json { render json: @subtitle_track_set, status: :created, location: @subtitle_track_set }
      else
        format.html { render action: "new" }
        format.json { render json: @subtitle_track_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subtitle_track_sets/1
  # PUT /subtitle_track_sets/1.json
  def update
    @subtitle_track_set = SubtitleTrackSet.find(params[:id])

    respond_to do |format|
      if @subtitle_track_set.update_attributes(params[:subtitle_track_set])
        format.html { redirect_to @subtitle_track_set, notice: 'Subtitle track set was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @subtitle_track_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subtitle_track_sets/1
  # DELETE /subtitle_track_sets/1.json
  def destroy
    @subtitle_track_set = SubtitleTrackSet.find(params[:id])
    @subtitle_track_set.destroy

    respond_to do |format|
      format.html { redirect_to subtitle_track_sets_url }
      format.json { head :ok }
    end
  end
end
