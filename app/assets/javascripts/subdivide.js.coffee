pad = (num, d) ->
  res = String(num)
  while res.length < d
    res = '0' + res
  return res

class TimePoint
  constructor: (@voice, @time, @type) ->
    @id = -1

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

  _onSaveSuccess: (data) =>
    @id = data['id']

  save: =>
    data = {
        voice: @voice,
        time: @time,
        time_point_type: @type
    }
    jQuery.ajax({
        type: 'POST',
        url: location.pathname + '/time_points.json',
        data: data,
        success: @_onSaveSuccess
    })

class Subtitle
  constructor: (@time_point, @text) ->

  handleClick: (event) ->
    if this.innerHTML == 'Enter text here..'
      this.innerHTML = ''

  handleKeypress: (event) ->
    if event.keyCode == 13  # return
      event.currentTarget.lastChild.blur()

  createDiv: (div_container) ->
    div = $('<div />')
    div.addClass('subtitle_edit_box')
    div.append($('<div />').addClass('startTime')
                           .append(@time_point.formatTime()))
    div.append($('<div />').addClass('voice')
                           .append('Voice ' + (@time_point.voice+1) + ':'))
    div.append($('<div />').addClass('subtitleText')
                           .prop('contenteditable', true)
                           .append('Enter text here..')
                           .click(@handleClick))
                           .keypress(@handleKeypress)
    @div = div
    return div

class Subdivide
  constructor: (@video, @time_points_div, @subtitle_edit_div) ->
    $(document).keydown @procKeyDown
    $(document).keyup @procKeyUp
    @time_points_div.mousedown @procMouseDown
    @time_points_div.mouseup @procMouseUp
    @time_points_div.css('width', @video.prop('width') - 147)
    @time_points = []
    @subtitles = []
    @shift_pressed = false
    @colors = ['blue', 'red', 'green', 'black']

  timeToWidth: (time) ->
    time / @video.prop('duration') * @time_points_div.width()

  addTimePoint: (voice, time, type) ->
    prev = -1
    for pt in @time_points
      if pt.voice == voice
        if pt.time == time
          return false
        if pt.type == false
          prev = pt.time
        else if time >= prev && time <= pt.time
          return false
      
    time_point = new TimePoint(voice, time, type)
    if type == false
      @time_points_div.append(
        time_point.createDiv(@colors[voice], @timeToWidth(time)))
      sub = new Subtitle(time_point, '')
      time_point.sub = sub
      div = sub.createDiv(@subtitle_edit_div)
      insert_index = -1
      for s, i in @subtitles
        if s.time_point.time > time
          insert_index = i
          break
      if insert_index == -1
        @subtitle_edit_div.append(div)
        @subtitles.push(sub)
      else
        div.insertBefore(@subtitles[insert_index].div)
        @subtitles.splice(insert_index, 0, sub)
      @setActiveSubtitle(div)
    else
      # find the immediately preceding time point of this voice
      prec = (pt for pt in @time_points when pt.time < time and pt.voice == voice)
      if prec.length > 0 && prec[prec.length-1].type == false
        pt = prec[prec.length-1]
        pt.div.css('width', @timeToWidth(time - pt.time))
      else
        return false

    time_point.save()
    @time_points.push(time_point)
    @time_points.sort((a,b) -> a.time - b.time)

  setActiveSubtitle: (div) ->
    @subtitle_edit_div.scrollTop(div.position().top)
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

  procMouseDown: (event) =>

  procMouseUp: (event) =>
    

$(document).ready(() ->
  new Subdivide $('#video'), $('#time_points'), $('#subtitle_edit')
)
