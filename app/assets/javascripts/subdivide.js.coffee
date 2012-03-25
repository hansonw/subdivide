EPSILON = 1e-4

pad = (num, d) ->
  res = String(num)
  while res.length < d
    res = '0' + res
  return res

timeEqual = (a, b) =>
  Math.abs(a-b) <= EPSILON

class Cuepoint
  constructor: (@video) ->
    @last_active = {}
    @video.bind("timeupdate", @_timeUpdate)

  _timeUpdate: =>
    @updateSubtitleDisplay()

  updateSubtitleDisplay: =>
    used = [false, false, false, false]
    active = {}
    first = true
    currentTime = @video.prop('currentTime')
    for subtitle in window.subdivide.subtitles
      if !subtitle.end_time || currentTime <= subtitle.end_time.time
        if currentTime >= subtitle.start_time.time - EPSILON
          if first == true && !@last_active[subtitle.id]
            window.subdivide.selectActiveSubtitle(subtitle)
            first = false
          active[subtitle.id] = 1
          $('.subtitle')[subtitle.start_time.voice].innerHTML = subtitle.text
          used[subtitle.start_time.voice] = true
    for flag,i in used
      $('.subtitle')[i].style.display = if flag then 'block' else 'none'
    @last_active = active

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
    div.css('top', 2 + @voice * 16)
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
        url: "/videos/" + video_id + '/time_points.json',
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
        url: "/videos/" + video_id + '/time_points/' + @id + '.json',
        data: data,
        success: @_onUpdateSuccess
    })

  updateWithEnd: =>
    data = {
        voice: @voice,
        time: @time,
        end: if @end != null then {
          id: @end.id,
          time: @end.time
        } else 'null'
        time_point_type: @type
    }
    jQuery.ajax({
        type: 'PUT',
        url: "/videos/" + video_id + '/time_points/' + @id + '.json',
        data: data,
        success: @_onUpdateSuccess
    })

  delete: =>
    if @div then @div.remove()
    jQuery.ajax({
        type: 'DELETE',
        url: "/videos/" + video_id + '/time_points/' + @id + '.json',
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
    event.currentTarget.style.color = '#333'
    @update()

  handleSkip: (event) =>
    event.stopPropagation()
    window.subdivide.setTime(
      if @end_time == null then @start_time.time else @end_time.time)

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
                            .click(-> false)
                            .keydown(@handleKeydown)
                            .blur(@handleStartTimeEdit))
    dat.append(' - ')
    dat.append($('<span />').addClass('endTime')
                            .prop('contenteditable', true)
                            .append(if @end_time then @end_time.formatTime() \
                                    else '?')
                            .click(-> false)
                            .keydown(@handleKeydown)
                            .blur(@handleEndTimeEdit))
    dat.append(' ')
    # I don't have to do anything for this; regular subtitle click works
    dat.append($('<span />').addClass('repeat control')
                            .append('&#8634;'))
    dat.append(' ')
    dat.append($('<span />').addClass('skip control')
                            .append('&crarr;')
                            .click(@handleSkip))
    dat.append($('<div />').addClass('delete control')
                           .append('&times;')
                           .click(@handleDelete))
    dat.append($('<div />').addClass('subtitleText')
                           .prop('contenteditable', true)
                           .click(-> false)
                           .css('color', if video_id == 2 then '#333' else '#999')
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
        url: "/videos/" + video_id + '/time_points/' + @start_time.id + '/subtitles.json',
        data: data,
        success: @_onCreateSuccess
    })

  update: =>
    data = {
        text: @text
    }
    jQuery.ajax({
        type: 'PUT',
        url: "/videos/" + video_id + '/time_points/' + @start_time.id + '/subtitles/' + @id + '.json',
        data: data,
        success: @_onUpdateSuccess
    })

  delete: =>
    if @div then @div.remove()
    jQuery.ajax({
        type: 'DELETE',
        url: "/videos/" + video_id + '/time_points/' + @start_time.id + '/subtitles/' + @id + '.json',
    })

class Subdivide
  constructor: (@video, @time_points_div, @time_marker, @subtitle_edit_div, @scrollbar) ->
    $(document).keydown @procKeyDown
    $(document).keyup @procKeyUp
    @barWidth = @video.prop('width') - 147
    @zoomWidth = @barWidth + 1
    @zoomLevel = 0
    @time_points_div.css('width', @barWidth)
    $('.slider-box').click(@procTimePointClick)
                    .disableSelection()
    @scrollbar.css('width', @barWidth)
    @scrollbar.jScrollPane({
      contentWidth: @barWidth+1,
    })
    @scrollbar.bind('jsp-scroll-x', @procScroll)
    @userScrolling = false
    $('.zoomin').click({dir: 1}, @procZoom)
    $('.zoomout').click({dir: -1}, @procZoom)
    $('.language_select').change(@initAgain)
    # Seeking the video should auto-scroll, always.
    @video.bind('seeking', => @userScrolling = false)
    @video.bind('timeupdate', @procTimeUpdate)
    @time_points = []
    @subtitles = []
    @shift_pressed = false
    for i in [1..4]
      $('.controls-'+i+' .start').click({voice: i-1, type: 0},
        (e) => @procControl(e))
      $('.controls-'+i+' .stop').click({voice: i-1, type: 1},
        (e) => @procControl(e))

  init: =>
    @loadTimePoints()
    @initJug()

  initAgain: =>
    for pt in @time_points
      if pt.div
        pt.div.remove()
    @time_points = []
    for sub in @subtitles
      if sub.div
        sub.div.remove()
    @subtitles = []
    window.video_id = parseInt($('.language_select option:selected').prop('value'))
    @loadTimePoints()
    @initJug()

  timeToPos: (time) =>
    return Math.ceil(time / @video.prop('duration') * @zoomWidth) -
      @scrollbar.data('jsp').getContentPositionX()

  posToTime: (pos) =>
    return (pos + @scrollbar.data('jsp').getContentPositionX()) / @zoomWidth *
      @video.prop('duration')

  updateTimePointDivs: ->
    prevVoice = {}
    for pt in @time_points
      if !pt.type
        prevVoice[pt.voice] = pt
        if pt.div == null
          $('.slider-box', @time_points_div).append(
            pt.createDiv(@timeToPos(pt.time)))
          pt.div.draggable({
            axis: 'x',
          })
          pt.div.resizable({
            handles: 'e, w',
            containment: 'parent',
            minWidth: 1,
          })
          pt.div.bind('drag', {timepoint: pt}, @procDrag)
          pt.div.bind('dragstop', {timepoint: pt}, @procDragStop)
          pt.div.bind('resize', {timepoint: pt}, @procResize)
          pt.div.bind('resizestop', {timepoint: pt}, @procResizeStop)
        else
          # in case anything was updated
          pt.div.css('left', @timeToPos(pt.time))
      else if prevVoice[pt.voice]
        prev = prevVoice[pt.voice]
        prev.end = pt
        prev.div.css('width', @timeToPos(pt.time) - @timeToPos(prev.time))
        if prev.sub
          prev.sub.end_time = pt
          prev.sub.updateTimes()

  updateTimeMarker: =>
    @time_marker.css('left', @timeToPos(@video.prop('currentTime')))

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
      pt[0].div.click((e) =>
        @setActiveSubtitle(sub)
        e.stopPropagation()
      )
      pt[0].sub = sub

  procUpdateSubtitle: (json) ->
    for sub in @subtitles
      if sub.id == json.id
        sub.text = json.text
        $('.subtitleText', sub.div).html(sub.text)

  procUpdateTimePoint: (json) ->
    for pt in @time_points
      if pt.id == json.id
        pt.time = parseFloat(json.time)
        if pt.sub != null && pt == pt.sub.start_time
          # preserve subtitle edit box ordering
          @subtitles.sort((a, b) -> a.start_time.time - b.start_time.time)
          i = @subtitles.indexOf(pt.sub)
          if i > 0
            pt.sub.div.insertAfter(@subtitles[i-1].div)
          else if i+1 < @subtitles.length
            pt.sub.div.insertBefore(@subtitles[i+1].div)
    @updateTimePointDivs()

  procDeleteTimePoint: (id) ->
    id = parseInt(id)
    @time_points = (pt for pt in @time_points when pt.id != id)

  procDeleteSubtitle: (id) ->
    id = parseInt(id)
    @subtitles = (sub for sub in @subtitles when sub.id != id)

  setTime: (time) =>
    # Force a time update.
    if timeEqual(@video.prop('currentTime'), time)
      @userScrolling = false
      @procTimeUpdate()
    else
      @video.prop('currentTime', time)

  setActiveSubtitle: (sub) ->
    @selectActiveSubtitle(sub)
    @setTime(sub.start_time.time)

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

  procControl: (event) =>
    @addTimePoint(event.data.voice, @video.prop('currentTime'),
                   event.data.type)

  procMouseDown: (event) =>

  procMouseUp: (event) =>

  procZoom: (event) =>
    dir = event.data.dir
    if dir == 1 || (dir == -1 && @zoomLevel > 0)
      @zoomLevel += dir
      @zoomWidth = @barWidth * (1 + @zoomLevel) + 1
      pct = @scrollbar.data('jsp').getContentPositionX() / @zoomWidth
      @scrollbar.data('jsp').scrollToX(0)
      @scrollbar.data('jsp').reinitialise({contentWidth: @zoomWidth})
      pct = Math.min(pct, 1 - 1/(1 + @zoomLevel))
      @scrollbar.data('jsp').scrollToX(pct * @zoomWidth)
      # hack: seems to not redraw properly for whatever reason. Force it
      @scrollbar.css('display', 'none')
      @scrollbar.css('display', '')
      @userScrolling = false

  procScroll: (event) =>
    @updateTimePointDivs()
    @updateTimeMarker()
    @userScrolling = true

  procTimeUpdate: (event) =>
    @updateTimeMarker()
    # If the user manually scrolled, don't auto-scroll.
    if @userScrolling
      return
    # Keep the marker within 20px of the slider bounds.
    bound = 20
    cur_pos = @scrollbar.data('jsp').getContentPositionX()
    cur_end = cur_pos + @barWidth
    mark_pos = parseInt(@time_marker.css('left'))
    diff = 0
    if mark_pos < bound && cur_pos > 0
      diff = bound - mark_pos
      @scrollbar.data('jsp').scrollToX(Math.max(0, cur_pos - diff))
    else if mark_pos > @barWidth - bound && cur_end < @zoomWidth
      diff = mark_pos - (@barWidth - bound)
      @scrollbar.data('jsp').scrollToX(
        Math.min(@zoomWidth - @barWidth, cur_pos + diff))
    @userScrolling = false

  procTimePointClick: (event) =>
    @video.prop('currentTime', @posToTime(event.offsetX))

  procDrag: (event, ui) =>
    pt = event.data.timepoint
    if pt.sub then @selectActiveSubtitle(pt.sub)
    return true

  procDragStop: (event, ui) =>
    pt = event.data.timepoint
    start = @posToTime(parseInt(pt.div.css('left')))
    end = if pt.end == null then start \
          else start + parseFloat(pt.end.time) - pt.time
    if start >= 0 && end <= @video.prop('duration')
      pt.time = start
      if pt.end != null then pt.end.time = end
      pt.updateWithEnd()

    @updateTimePointDivs()
    if pt.sub then @setActiveSubtitle(pt.sub)

  procResize: (event, ui) =>
    pt = event.data.timepoint
    if pt.sub then @selectActiveSubtitle(pt.sub)
    return true

  procResizeStop: (event, ui) =>
    pt = event.data.timepoint
    start = ui.position.left
    width = ui.size.width
    if start == ui.originalPosition.left
      if width != ui.originalSize.width
        if pt.end == null 
          pt.end = new TimePoint(pt.voice, @posToTime(start + width), 1)
          pt.end.create()
        else
          pt.end.time = @posToTime(start + width)
          pt.end.update()
    else
      orig_time = pt.time
      pt.time = @posToTime(start)
      pt.update()
      if pt.end == null
        pt.end = new TimePoint(pt.voice, orig_time, 1)
        pt.end.create()

    @updateTimePointDivs()
    if pt.sub then @setActiveSubtitle(pt.sub)

  initJug: =>
    window.jug = new Juggernaut({
      secure: false,
      host: 'simple-earth-9425.herokuapp.com',
      port: 80,
      transports: ['xhr-polling', 'jsonp-polling']
    })
    jug.subscribe(channel_name_map[video_id], (data) =>
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
        url: "/videos/" + video_id + '/time_points.json',
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
        url: "/videos/" + video_id + '/time_points/' + time_point_id + '/subtitles.json',
        success: (data) =>
          for value in data
            @procAddSubtitle(value)
            @procUpdateSubtitle(value)
    })

$(document).ready(() ->
  $('#video')[0].addEventListener('durationchange', () ->
    window.subdivide = new Subdivide $('#video'), $('#time_points'), $('#time_marker'), $('#subtitle_edit'), $('#scrollbar')
    window.subdivide.init()
    window.cuepoint = new Cuepoint $('#video')
  )
  $('#help_close').click(-> $('#help').css('display', 'none'))
)
