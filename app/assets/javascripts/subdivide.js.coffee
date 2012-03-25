class Util
  @EPSILON = 1e-4

  @pad: (num, d) ->
    res = String(num)
    while res.length < d
      res = '0' + res
    return res

  @timeEqual: (a, b) ->
    Math.abs(a-b) <= @EPSILON

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

  @formatTime: (time) ->
    h = Math.floor(time / 3600)
    m = Math.floor(time / 60)
    s = Math.floor(time) % 60
    ms = Math.floor((time - Math.floor(time)) * 1000)
    return h + ':' + @pad(m, 2) + ':' + @pad(s, 2) + '.' + @pad(ms, 3)

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
        if currentTime >= subtitle.start_time - Util.EPSILON
          if first == true && !@last_active[subtitle.id]
            window.subdivide.selectActiveSubtitle(subtitle)
            first = false
          active[subtitle.id] = 1
          $('.subtitle')[subtitle.voice].innerHTML = subtitle.text
          used[subtitle.voice] = true
    for flag,i in used
      $('.subtitle')[i].style.display = if flag then 'block' else 'none'
    @last_active = active

class Subtitle
  constructor: (@voice, @start_time, @end_time, @text) ->
    @id = -1
    @div = null
    @time_div = null

  handleKeydown: (event) =>
    event.stopPropagation()
    if event.keyCode == 13  # return
      event.currentTarget.blur()

  handleStartTimeEdit: (event) =>
    new_time = Util.parseTime(event.currentTarget.innerHTML)
    if new_time == null
      event.currentTarget.innerHTML = Util.formatTime(@start_time)
    else
      @start_time = new_time
      @update()

  handleEndTimeEdit: (event) =>
    new_time = Util.parseTime(event.currentTarget.innerHTML)
    if new_time == null || new_time <= @start_time
      event.currentTarget.innerHTML =
        if @end_time == null then Util.formatTime(@end_time) else '?'
    else
      @end_time = new_time

  handleTextEdit: (event) =>
    @text = event.currentTarget.innerHTML
    event.currentTarget.style.color = '#333'
    @update()

  handleSkip: (event) =>
    event.stopPropagation()
    window.subdivide.setTime(
      if @end_time == null then @start_time else @end_time.time)

  handleDelete: =>
    @delete()

  createDiv: ->
    div = $('<div />')
    div.addClass('subtitle_edit_box')
    div.append($('<div />').addClass('voice')
                           .append(@voice+1))
    dat = $('<div />').addClass('subtitle_data')
    dat.append($('<span />').addClass('startTime')
                            .prop('contenteditable', true)
                            .append(Util.formatTime(@start_time))
                            .click(-> false)
                            .keydown(@handleKeydown)
                            .blur(@handleStartTimeEdit))
    dat.append(' - ')
    dat.append($('<span />').addClass('endTime')
                            .prop('contenteditable', true)
                            .append(if @end_time then Util.formatTime(@end_time) \
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

  createTimeDiv: (pos, width) =>
    div = $('<div />')
    div.addClass('slider')
    div.css('left', pos)
    if width != null
      div.css('width', width)
    div.css('top', 2 + @voice * 16)
    @time_div = div
    return div

  updateDiv: ->
    $('.startTime', @div).html(Util.formatTime(@start_time))
    $('.endTime', @div).html(Util.formatTime(@end_time))
    $('.subtitleText', @div).html(@text)

  _onCreateSuccess: (data) =>
    @id = data['id']

  _onUpdateSuccess: (data) =>

  create: =>
    data = {
        video: @video,
        voice: @voice,
        start_time: @start_time,
        end_time: @end_time,
        text: @text
    }
    jQuery.ajax({
        type: 'POST',
        url: "/videos/" + video_id + '/subtitles.json',
        data: data,
        success: @_onCreateSuccess
    })

  update: =>
    data = {
        voice: @voice,
        start_time: @start_time,
        end_time: @end_time,
        text: @text
    }
    jQuery.ajax({
        type: 'PUT',
        url: "/videos/" + video_id + '/subtitles/' + @id + '.json',
        data: data,
        success: @_onUpdateSuccess
    })

  delete: =>
    if @div then @div.remove()
    if @time_div then @time_div.remove()
    jQuery.ajax({
        type: 'DELETE',
        url: "/videos/" + video_id + '/subtitles/' + @id + '.json',
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
    @subtitles = []
    @shift_pressed = false
    for i in [1..4]
      $('.controls-'+i+' .start').click({voice: i-1, type: false},
        (e) => @procControl(e))
      $('.controls-'+i+' .stop').click({voice: i-1, type: true},
        (e) => @procControl(e))

  init: =>
    @loadSubtitles()
    @initJug()

  initAgain: =>
    for sub in @subtitles
      sub.div.remove()
      sub.time_div.remove()
    @subtitles = []
    window.video_id = parseInt($('.language_select option:selected').prop('value'))
    @loadSubtitles()
    @initJug()

  timeToPos: (time) =>
    return Math.ceil(time / @video.prop('duration') * @zoomWidth) -
      @scrollbar.data('jsp').getContentPositionX()

  posToTime: (pos) =>
    return (pos + @scrollbar.data('jsp').getContentPositionX()) / @zoomWidth *
      @video.prop('duration')

  updateTimeDivs: ->
    for sub in @subtitles
      sp = @timeToPos(sub.start_time)
      w = if sub.end_time != null then @timeToPos(sub.end_time) - sp else null
      if sub.time_div == null
        $('.slider-box', @time_points_div).append(sub.createTimeDiv(sp, w))
        sub.time_div.draggable({
          axis: 'x',
        })
        sub.time_div.resizable({
          handles: 'e, w',
          containment: 'parent',
          minWidth: 1,
        })
        sub.time_div.bind('drag', {subtitle: sub}, @procDrag)
        sub.time_div.bind('dragstop', {subtitle: sub}, @procDragStop)
        sub.time_div.bind('resize', {subtitle: sub}, @procResize)
        sub.time_div.bind('resizestop', {subtitle: sub}, @procResizeStop)
      else
        # in case anything was updated
        sub.time_div.css('left', sp)
        if w != null
          sub.time_div.css('width', w)

  updateTimeMarker: =>
    @time_marker.css('left', @timeToPos(@video.prop('currentTime')))

  addTimePoint: (voice, time, is_end) =>
    if is_end
      before = (sub for sub in @subtitles when sub.start_time <= time && sub.voice == voice)
      if before.length > 0
        sub = before[before.length - 1]
        if sub.end_time == null
          sub.end_time = time
          sub.update()
    else
      sub = new Subtitle(voice, time, null, 'speech')
      sub.create()
  
  createSubtitleDivs: ->
    prev = null
    for sub in @subtitles
      if !sub.div
        sub.createDiv()
        if prev == null
          @subtitle_edit_div.prepend(sub.div)
        else
          sub.div.insertAfter(prev.div)
      prev = sub

  procAddSubtitle: (data) ->
    sub = new Subtitle(data.voice, data.start_time, data.end_time, data.text)
    sub.id = data.id
    @subtitles.push(sub)
    @subtitles.sort((a, b) -> a.start_time - b.start_time)
    @createSubtitleDivs()
    @updateTimeDivs()
    sub.div.click(=> @setActiveSubtitle(sub))
    sp = @timeToPos(sub.start_time)
    w = if sub.end_time != null then @timeToPos(sub.end_time) - sp else null
    sub.time_div.click((e) =>
      @setActiveSubtitle(sub)
      e.stopPropagation()
    )

  procUpdateSubtitle: (data) ->
    for sub in @subtitles
      if sub.id == data.id
        sub.voice = data.voice
        sub.start_time = data.start_time
        sub.end_time = data.end_time
        sub.text = data.text
        sub.updateDiv()
        # preserve subtitle edit box ordering
        @subtitles.sort((a, b) -> a.start_time - b.start_time)
        i = @subtitles.indexOf(sub)
        if i > 0
          sub.div.insertAfter(@subtitles[i-1].div)
        else if i+1 < @subtitles.length
          sub.div.insertBefore(@subtitles[i+1].div)
        @updateTimeDivs()
        break

  procDeleteSubtitle: (id) ->
    id = parseInt(id)
    @subtitles = (sub for sub in @subtitles when sub.id != id)

  setTime: (time) =>
    # Force a time update.
    if Util.timeEqual(@video.prop('currentTime'), time)
      @userScrolling = false
      @procTimeUpdate()
    else
      @video.prop('currentTime', time)

  setActiveSubtitle: (sub) ->
    @selectActiveSubtitle(sub)
    @setTime(sub.start_time)

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
      @addTimePoint event.keyCode-voice_min, @video.prop('currentTime'), @shift_pressed

  procKeyUp: (event) =>
    if event.keyCode == 16 # shift
      @shift_pressed = false

  procControl: (event) =>
    @addTimePoint(event.data.voice, @video.prop('currentTime'), event.data.type)

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
    @updateTimeDivs()
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
    sub = event.data.subtitle
    @selectActiveSubtitle(sub)

  procDragStop: (event, ui) =>
    sub = event.data.subtitle
    start = @posToTime(parseInt(sub.time_div.css('left')))
    end = if sub.end_time == null then start \
          else start + sub.end_time - sub.start_time
    if start >= 0 && end <= @video.prop('duration')
      sub.start_time = start
      sub.end_time = end
      sub.update()
    
    @updateTimeDivs()
    @setActiveSubtitle(sub)

  procResize: (event, ui) =>
    sub = event.data.subtitle
    @selectActiveSubtitle(sub)

  procResizeStop: (event, ui) =>
    sub = event.data.subtitle
    start = ui.position.left
    width = ui.size.width
    if start == ui.originalPosition.left
      sub.end_time = @posToTime(start + width)
    else
      sub.start_time = @posToTime(start)
    sub.update()
    @updateTimeDivs()
    @setActiveSubtitle(sub)

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
      else if data.type == 'create_subtitle'
        @procAddSubtitle(data.value)
      else if data.type == 'delete_subtitle'
        @procDeleteSubtitle(data.value)
      else
        console.log('Unknown type ' + data.type)
      window.cuepoint.updateSubtitleDisplay()
    )

  loadSubtitles: =>
    jQuery.ajax({
        type: 'GET',
        url: "/videos/" + video_id + '/subtitles.json',
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
