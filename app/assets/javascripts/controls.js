var initializeControls = function(video){
  //Time format converter - 00:00
  var timeFormat = function(seconds){
    var m = Math.floor(seconds/60)<10 ? "0"+Math.floor(seconds/60) : Math.floor(seconds/60);
    var s = Math.floor(seconds-(m*60))<10 ? "0"+Math.floor(seconds-(m*60)) : Math.floor(seconds-(m*60));
    return m+":"+s;
  };

  //set video properties
  $('.current').text(timeFormat(0));
  $('.duration').text(timeFormat(video.duration()));
  //updateVolume(0, 0.7);
    
  //start to get video buffering data 
  setTimeout(startBuffer, 150);
  
  //bind video events
  $('#subtitle_container')
  .on('click', function() {
    $('.btnPlay').addClass('paused');
    $(this).unbind('click');
    video.play()
  });
  
  //display video buffering bar
  var startBuffer = function() {
    var perc = video.getBufferedPercent();
    $('.bufferBar').css('width',perc+'%');
    if(perc < 99.9) {
      setTimeout(startBuffer, 500);
    }
  };  
  
  //display current video play time
  video.onTimeUpdate(function() {
    var currentPos = video.currentTime();
    var maxduration = video.duration();
    var perc = 100 * currentPos / maxduration;
    $('.timeBar').css('width',perc+'%');  
    $('.current').text(timeFormat(currentPos)); 
    if ($('.duration').text() == '00:00') {
      $('.duration').text(timeFormat(video.duration()));
    }
  });
  
  //CONTROLS EVENTS
  //video screen and play button clicked
  $('.btnPlay').on('click', function() { playpause(); } );
  var playpause = function() {
    if(video.paused()) {
      $('.btnPlay').addClass('paused');
      video.play();
    }
    else {
      $('.btnPlay').removeClass('paused');
      video.pause();
    }
  };
  
  //sound button clicked
  $('.sound').click(function() {
    video[0].muted = !video[0].muted;
    $(this).toggleClass('muted');
    if(video[0].muted) {
      $('.volumeBar').css('width',0);
    }
    else{
      $('.volumeBar').css('width', video[0].volume*100+'%');
    }
  });
  
  //VIDEO EVENTS
  //video ended event
  video.onEnd(function() {
    $('.btnPlay').removeClass('paused');
    video.pause();
  });

  //VIDEO PROGRESS BAR
  //when video timebar clicked
  var timeDrag = false; /* check for drag event */
  $('.progress').on('mousedown', function(e) {
    timeDrag = true;
    updatebar(e.pageX);
  });
  $(document).on('mouseup', function(e) {
    if(timeDrag) {
      timeDrag = false;
      updatebar(e.pageX);
    }
  });
  $(document).on('mousemove', function(e) {
    if(timeDrag) {
      updatebar(e.pageX);
    }
  });
  var updatebar = function(x) {
    var progress = $('.progress');
    //calculate drag position
    //and update video currenttime
    //as well as progress bar
    var maxduration = video.duration();
    var position = x - progress.offset().left;
    var percentage = 100 * position / progress.width();
    if(percentage > 100) {
      percentage = 100;
    }
    if(percentage < 0) {
      percentage = 0;
    }
    $('.timeBar').css('width',percentage+'%');  
    video.seekTo(maxduration * percentage / 100);
  };

  //VOLUME BAR
  //volume bar event
  var volumeDrag = false;
  $('.volume').on('mousedown', function(e) {
    volumeDrag = true;
    video[0].muted = false;
    $('.sound').removeClass('muted');
    updateVolume(e.pageX);
  });
  $(document).on('mouseup', function(e) {
    if(volumeDrag) {
      volumeDrag = false;
      updateVolume(e.pageX);
    }
  });
  $(document).on('mousemove', function(e) {
    if(volumeDrag) {
      updateVolume(e.pageX);
    }
  });
  var updateVolume = function(x, vol) {
    var volume = $('.volume');
    var percentage;
    //if only volume have specificed
    //then direct update volume
    if(vol) {
      percentage = vol * 100;
    }
    else {
      var position = x - volume.offset().left;
      percentage = 100 * position / volume.width();
    }
    
    if(percentage > 100) {
      percentage = 100;
    }
    if(percentage < 0) {
      percentage = 0;
    }
    
    //update volume bar and video volume
    $('.volumeBar').css('width',percentage+'%');  
    video[0].volume = percentage / 100;
    
    //change sound icon based on volume
    if(video[0].volume == 0){
      $('.sound').removeClass('sound2').addClass('muted');
    }
    else if(video[0].volume > 0.5){
      $('.sound').removeClass('muted').addClass('sound2');
    }
    else{
      $('.sound').removeClass('muted').removeClass('sound2');
    }
    
  };
};
