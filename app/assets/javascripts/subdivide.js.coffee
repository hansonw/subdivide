class TimePoint
  constructor: (@voice, @time, @type) ->

  save: =>
    data = {
        voice: @voice,
        time: @time,
        time_point_type: @type
    }
    jQuery.ajax({
        type: 'POST',
        url: '/time_points.json',
        data: data,
        succcess: (data) ->
          console.log data
          console.log data[id]
    })

class Subtitle
  constructor: (@time_point, @text) ->

class Subdivide
  constructor: (@video, @time_points_div, @subtitle_edit_div) ->
    $(document).keydown $.proxy(@procKeyDown, @)
    $(document).keyup $.proxy(@procKeyUp, @)
    @time_points_div.mousedown $.proxy(@procMouseDown, @)
    @time_points_div.mouseup $.proxy(@procMouseUp, @)
    @time_points_div.css('width', @video.prop('width') - 147)
    @time_points = []
    @shift_pressed = false

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
      div = $('<div />')
      div.addClass('slider')
      div.css('left', @timeToWidth(time))
      div.css('top', 10 + voice * 15)
      time_point.div = div
      @time_points_div.append(time_point.div)
    else
      # find the immediately preceding time point of this voice
      prec = (pt for pt in @time_points when pt.time < time and pt.voice == voice)
      if prec.length > 0 && prec[prec.length-1].type == false
        pt = prec[prec.length-1]
        pt.div.css('width', @timeToWidth(time - pt.time))
        console.log(prec)
      else
        return false

    time_point.save()
    @time_points.push(time_point)
    @time_points.sort((a,b) -> a.time - b.time)
    console.log(@time_points)

  procKeyDown: (event) ->
    voice_min = '1'.charCodeAt(0)
    voice_max = voice_min + 3
    if event.keyCode == 16 # shift
      @shift_pressed = true
    else if event.keyCode >= voice_min && event.keyCode <= voice_max
      @addTimePoint event.keyCode-voice_min, @video.prop('currentTime'), @shift_pressed

  procKeyUp: (event) ->
    if event.keyCode == 16 # shift
      @shift_pressed = false

  procMouseDown: (event) ->

  procMouseUp: (event) ->
    

$(document).ready(() ->
  new Subdivide $('#video'), $('#time_points'), $('#subtitle_edit')
)
