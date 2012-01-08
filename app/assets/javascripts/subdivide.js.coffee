pad = (num, d) ->
  res = String(num)
  while res.length < d
    res = '0' + res
  return res

class TimePoint
  constructor: (@voice, @time, @type) ->
    @id = -1
    @sub = null
    @div = null

  formatTime: () ->
    h = Math.floor(@time / 3600)
    m = Math.floor(@time / 60)
    s = Math.floor(@time) % 60
    ms = Math.floor((@time - Math.floor(@time)) * 60)
    return h + ':' + pad(m, 2) + ':' + pad(s, 2) + '.' + pad(ms, 3)

  createDiv: (color, pos) ->
    div = $('<div />')
    div.addClass('slider')
    div.css('left', pos)
    div.css('top', 10 + @voice * 15)
    div.css('background', color)
    @div = div
    return div

  _onCreateSuccess: (data) =>
    @id = data['id']
    if !@type
      sub = new Subtitle(@, '')
      sub.create()

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

class Subtitle
  constructor: (@start_time, @text) ->
    @id = -1
    @end_time = null
    @div = null

  handleKeypress: (event) =>
    if event.keyCode == 13  # return
      event.currentTarget.blur()
      @text = event.currentTarget.innerHTML
      @update()

  createDiv: ->
    div = $('<div />')
    div.addClass('subtitle_edit_box')
    div.append($('<span />').addClass('startTime')
                           .append(@start_time.formatTime()))
    div.append(' - ')
    div.append($('<span />').addClass('endTime')
                           .append(@start_time.formatTime()))
    div.append($('<div />').addClass('voice')
                           .append('Voice ' + (@start_time.voice+1) + ':'))
    div.append($('<div />').addClass('subtitleText')
                           .prop('contenteditable', true)
                           .append('..')
                           .keypress(@handleKeypress))
    @div = div
    return div

  updateTimes: ->
    $('.startTime', @div).replaceWith(@start_time.formatTime())
    $('.endTime', @div).replaceWith(@end_time.formatTime())

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
    @colors = ['blue', 'red', 'green', 'black']

  init: =>
    @loadTimePoints()
    @initJug()

  timeToWidth: (time) ->
    Math.ceil(time / @video.prop('duration') * @time_points_div.width())

  createTimePointDivs: ->
    prevVoice = {}
    for pt in @time_points
      if !pt.type
        prevVoice[pt.voice] = pt
        if pt.div == null
          @time_points_div.append(
            pt.createDiv(@colors[pt.voice], @timeToWidth(pt.time)))
      else if prevVoice[pt.voice]
        prev = prevVoice[pt.voice]
        prev.div.css('width', @timeToWidth(pt.time - prev.time))
        if prev.sub
          prev.sub.end_time = pt
          prev.sub.updateTimes()

  createSubtitleDivs: ->
    prev = null
    console.log(@subtitles)
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
    @createTimePointDivs()

  procAddSubtitle: (json) ->
    pt = (pt for pt in @time_points when pt.id == json.time_point_id)
    if pt.length > 0
      sub = new Subtitle(pt[0], json.text)
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

  setActiveSubtitle: (sub) ->
    div = sub.div
    @subtitle_edit_div.scrollTop(div.position().top)
    $('.subtitle_edit_box').removeClass('selected')
    div.addClass('selected')
    @video.prop('currentTime', sub.start_time.time)
  
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

  procMouseDown: (event) =>

  procMouseUp: (event) =>

  initJug: =>
    window.jug = new Juggernaut({
      secure: false,
      host: 'simple-earth-9425.herokuapp.com',
      port: 80,
      transports: ['xhr-polling', 'jsonp-polling']
    })
    jug.subscribe("channel1", (data) =>
      if data.type == 'update_subtitle'
        @procUpdateSubtitle(data.value)
      else if data.type == 'create_time_point'
        @procAddTimePoint(data.value)
      else if data.type == 'create_subtitle'
        @procAddSubtitle(data.value)
    )
  
  loadTimePoints: =>
    jQuery.ajax({
        type: 'GET',
        url: location.pathname + '/time_points.json',
        success: (data) =>
          for value in data
            @procAddTimePoint(value)
            @loadSubtitles(value['id'])
    })

  loadSubtitles: (time_point_id) =>
    jQuery.ajax({
        type: 'GET',
        url: location.pathname + '/time_points/' + time_point_id + '/subtitles.json',
        success: (data) =>
          for value in data
            @procAddSubtitle(value)
    })

$(document).ready(() ->
  window.subdivide = new Subdivide $('#video'), $('#time_points'), $('#subtitle_edit')
  window.subdivide.init()
)
