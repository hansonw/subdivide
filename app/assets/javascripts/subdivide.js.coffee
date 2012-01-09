pad = (num, d) ->
  res = String(num)
  while res.length < d
    res = '0' + res
  return res

class Cuepoint
  constructor: (@video, @marker) ->
    @last_active = {}
    @video[0].addEventListener("timeupdate", @_timeUpdate)

  _timeUpdate: =>
    @updateSubtitleDisplay()
    @updateTimeMarker()

  updateSubtitleDisplay: =>
    used = [false, false, false, false]
    active = {}
    first = true
    currentTime = @video.prop('currentTime')
    for subtitle in window.subdivide.subtitles
      if !subtitle.end_time || currentTime <= subtitle.end_time.time
        if currentTime >= subtitle.start_time.time
          if first == true && !@last_active[subtitle.id]
            window.subdivide.selectActiveSubtitle(subtitle)
            first = false
          active[subtitle.id] = 1
          $('.subtitle')[subtitle.start_time.voice].innerHTML = subtitle.text
          used[subtitle.start_time.voice] = true
    for flag,i in used
      $('.subtitle')[i].style.display = if flag then 'block' else 'none'
    @last_active = active

  updateTimeMarker: =>
    @marker.css('left',
      window.subdivide.timeToWidth(@video.prop('currentTime')))

class TimePoint
  constructor: (@voice, @time, @type) ->
    @id = -1
    @end = null
    @sub = null
    @div = null

  @parseTime: (str) =>
    parts = str.split(':')
    if parts.length == 0
      return null
    t = 0
    for p in parts
      f = parseFloat(p)
      if f == NaN
        return null
      t = t * 60 + f
    return t
    
  formatTime: () ->
    h = Math.floor(@time / 3600)
    m = Math.floor(@time / 60)
    s = Math.floor(@time) % 60
    ms = Math.floor((@time - Math.floor(@time)) * 1000)
    return h + ':' + pad(m, 2) + ':' + pad(s, 2) + '.' + pad(ms, 3)

  createDiv: (pos) ->
    div = $('<div />')
    div.addClass('slider')
    div.css('left', pos)
    div.css('top', 10 + @voice * 16)
    @div = div
    return div

  _onCreateSuccess: (data) =>
    @id = data['id']
    if !@type
      sub = new Subtitle(@, 'speech')
      sub.create()

  _onUpdateSuccess: (data) =>

  create: =>
    data = {
        voice: @voice,
        time: @time,
        time_point_type: @type
    }
    jQuery.ajax({
        type: 'POST',
        url: location.pathname + '/time_points.json',
        data: data,
        success: @_onCreateSuccess
    })

  update: =>
    data = {
        voice: @voice,
        time: @time,
        time_point_type: @type
    }
    jQuery.ajax({
        type: 'PUT',
        url: location.pathname + '/time_points/' + @id + '.json',
        data: data,
        success: @_onUpdateSuccess
    })

  delete: =>
    if @div then @div.remove()
    jQuery.ajax({
        type: 'DELETE',
        url: location.pathname + '/time_points/' + @id + '.json',
    })

class Subtitle
  constructor: (@start_time, @text) ->
    @id = -1
    @end_time = null
    @div = null

  handleKeydown: (event) =>
    event.stopPropagation()
    if event.keyCode == 13  # return
      event.currentTarget.blur()

  handleStartTimeEdit: (event) =>
    new_time = TimePoint.parseTime(event.currentTarget.innerHTML)
    if new_time == null
      event.currentTarget.innerHTML = @start_time.formatTime()
    else
      @start_time.time = new_time
      @start_time.update()

  handleEndTimeEdit: (event) =>
    new_time = TimePoint.parseTime(event.currentTarget.innerHTML)
    if new_time == null || new_time <= @start_time.time
      event.currentTarget.innerHTML =
        if @end_time then @end_time.formatTime() \
        else '?'
    else
      if @end_time == null
        @end_time = new TimePoint(@start_time.voice, new_time, 1)
        @end_time.create()
      else
        @end_time.time = new_time
        @end_time.update()

  handleTextEdit: (event) =>
    @text = event.currentTarget.innerHTML
    @update()

  handleDelete: =>
    @delete()
    @start_time.delete()
    if @end_time
      @end_time.delete()

  createDiv: ->
    div = $('<div />')
    div.addClass('subtitle_edit_box')
    div.append($('<div />').addClass('voice')
                           .append(@start_time.voice+1))
    dat = $('<div />').addClass('subtitle_data')
    dat.append($('<span />').addClass('startTime')
                            .prop('contenteditable', true)
                            .append(@start_time.formatTime())
                            .keydown(@handleKeydown)
                            .blur(@handleStartTimeEdit))
    dat.append(' - ')
    dat.append($('<span />').addClass('endTime')
                            .prop('contenteditable', true)
                            .append(if @end_time then @end_time.formatTime() \
                                    else '?')
                            .keydown(@handleKeydown)
                            .blur(@handleEndTimeEdit))
    dat.append($('<div />').addClass('delete')
                           .append($('<a href="#"/>').append('&times;'))
                           .click(@handleDelete))
    dat.append($('<div />').addClass('subtitleText')
                           .prop('contenteditable', true)
                           .append(@text)
                           .keydown(@handleKeydown)
                           .blur(@handleTextEdit))
    div.append(dat);
    @div = div
    return div

  updateTimes: ->
    $('.startTime', @div).html(@start_time.formatTime())
    $('.endTime', @div).html(@end_time.formatTime())

  _onCreateSuccess: (data) =>
    @id = data['id']

  _onUpdateSuccess: (data) =>

  create: =>
    data = {
        text: @text
    }
    jQuery.ajax({
        type: 'POST',
        url: location.pathname + '/time_points/' + @start_time.id + '/subtitles.json',
        data: data,
        success: @_onCreateSuccess
    })

  update: =>
    data = {
        text: @text
    }
    jQuery.ajax({
        type: 'PUT',
        url: location.pathname + '/time_points/' + @start_time.id + '/subtitles/' + @id + '.json',
        data: data,
        success: @_onUpdateSuccess
    })

  delete: =>
    if @div then @div.remove()
    jQuery.ajax({
        type: 'DELETE',
        url: location.pathname + '/time_points/' + @start_time.id + '/subtitles/' + @id + '.json',
    })

class Subdivide
  constructor: (@video, @time_points_div, @subtitle_edit_div) ->
    $(document).keydown @procKeyDown
    $(document).keyup @procKeyUp
    @time_points_div.mouseover
    @time_points_div.mousedown @procMouseDown
    @time_points_div.mouseup @procMouseUp
    @time_points_div.css('width', @video.prop('width') - 147)
    @time_points = []
    @subtitles = []
    @shift_pressed = false

  init: =>
    @loadTimePoints()
    @initJug()

  timeToWidth: (time) ->
    Math.ceil(time / @video.prop('duration') * @time_points_div.width())

  updateTimePointDivs: ->
    prevVoice = {}
    for pt in @time_points
      if !pt.type
        prevVoice[pt.voice] = pt
        if pt.div == null
          @time_points_div.append(
            pt.createDiv(@timeToWidth(pt.time)))
        else
          # in case anything was updated
          pt.div.css('left', @timeToWidth(pt.time))
      else if prevVoice[pt.voice]
        prev = prevVoice[pt.voice]
        prev.end = pt
        prev.div.css('width', @timeToWidth(pt.time - prev.time))
        if prev.sub
          prev.sub.end_time = pt
          prev.sub.updateTimes()

  createSubtitleDivs: ->
    prev = null
    for sub in @subtitles
      if !sub.div
        sub.div = sub.createDiv()
        if prev == null
          @subtitle_edit_div.prepend(sub.div)
        else
          sub.div.insertAfter(prev.div)
      prev = sub

  addTimePoint: (voice, time, type) ->
    time_point = new TimePoint(voice, time, type)
    time_point.create()

  procAddTimePoint: (json) ->
    time_point = new TimePoint(json.voice, json.time, json.time_point_type)
    time_point.id = json.id
    @time_points.push(time_point)
    @time_points.sort((a, b) -> a.time - b.time)
    @updateTimePointDivs()

  procAddSubtitle: (json) ->
    pt = (pt for pt in @time_points when pt.id == json.time_point_id)
    if pt.length > 0
      sub = new Subtitle(pt[0], json.text)
      if pt[0].end
        sub.end_time = pt[0].end
      sub.id = json.id
      @subtitles.push(sub)
      @subtitles.sort((a, b) -> a.start_time.time - b.start_time.time)
      @createSubtitleDivs()
      sub.div.click(=> @setActiveSubtitle(sub))
      pt[0].div.click(=> @setActiveSubtitle(sub))
      pt[0].sub = sub

  procUpdateSubtitle: (json) ->
    for sub in @subtitles
      if sub.id == json.id
        sub.text = json.text
        $('.subtitleText', sub.div).html(sub.text)

  procUpdateTimePoint: (json) ->
    for pt in @time_points
      if pt.id == json.id
        pt.time = json.time
    @updateTimePointDivs()

  procDeleteTimePoint: (id) ->
    id = parseInt(id)
    @time_points = (pt for pt in @time_points when pt.id != id)

  procDeleteSubtitle: (id) ->
    id = parseInt(id)
    console.log(@subtitles)
    console.log(id)
    @subtitles = (sub for sub in @subtitles when sub.id != id)

  setActiveSubtitle: (sub) ->
    @selectActiveSubtitle(sub)
    @video.prop('currentTime', sub.start_time.time)

  selectActiveSubtitle: (sub) ->
    div = sub.div
    @subtitle_edit_div.scrollTop(div.position().top + @subtitle_edit_div.scrollTop())
    $('.subtitle_edit_box').removeClass('selected')
    div.addClass('selected')
  
  procKeyDown: (event) =>
    voice_min = '1'.charCodeAt(0)
    voice_max = voice_min + 3
    if event.keyCode == 16 # shift
      @shift_pressed = true
    else if event.keyCode >= voice_min && event.keyCode <= voice_max
      @addTimePoint event.keyCode-voice_min, @video.prop('currentTime'), if @shift_pressed then 1 else 0

  procKeyUp: (event) =>
    if event.keyCode == 16 # shift
      @shift_pressed = false

  procMouseDown: (event) =>

  procMouseUp: (event) =>

  initJug: =>
    window.jug = new Juggernaut({
      secure: false,
      host: 'simple-earth-9425.herokuapp.com',
      port: 80,
      transports: ['xhr-polling', 'jsonp-polling']
    })
    jug.subscribe(get_channel_name(), (data) =>
      console.log(data)
      if data.type == 'update_subtitle'
        @procUpdateSubtitle(data.value)
      else if data.type == 'update_time_point'
        @procUpdateTimePoint(data.value)
      else if data.type == 'create_subtitle'
        @procAddSubtitle(data.value)
      else if data.type == 'create_time_point'
        @procAddTimePoint(data.value)
      else if data.type == 'delete_time_point'
        @procDeleteTimePoint(data.value)
      else if data.type == 'delete_subtitle'
        @procDeleteSubtitle(data.value)
      else
        console.log('Unknown type ' + data.type)
      window.cuepoint.updateSubtitleDisplay()
    )
  
  loadTimePoints: =>
    jQuery.ajax({
        type: 'GET',
        url: location.pathname + '/time_points.json',
        success: (data) =>
          for value in data
            @procAddTimePoint(value)
          # subtitles can only be loaded after ALL time points have been created
          for value in data
            @loadSubtitles(value['id'])
    })

  loadSubtitles: (time_point_id) =>
    jQuery.ajax({
        type: 'GET',
        url: location.pathname + '/time_points/' + time_point_id + '/subtitles.json',
        success: (data) =>
          for value in data
            @procAddSubtitle(value)
            @procUpdateSubtitle(value)
    })

$(document).ready(() ->
  $('#video')[0].addEventListener('durationchange', () ->
    window.subdivide = new Subdivide $('#video'), $('#time_points'), $('#subtitle_edit')
    window.subdivide.init()
    window.cuepoint = new Cuepoint $('#video'), $('#time_marker')
  )
  $('#help_close').click(-> $('#help').css('display', 'none'))
)
