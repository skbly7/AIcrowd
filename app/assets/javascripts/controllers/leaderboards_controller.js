function startVideoPlayers(){
  var $videos = $('video');
  if ($videos.is(':in-viewport')) {
    $videos.each(function(){
      console.log('starting video: ' + this);
      var playPromise = this.play();
    });
  }
}

function pauseAndPlay(){
  var scrollTimeout = null;
  $(window).scroll(function(){
    if (scrollTimeout) {
      clearTimeout(scrollTimeout);
    }
    scrollTimeout = setTimeout(function() {
      startVideoPlayers();
    }, 2000);
  });
}


function copyLink() {
  var hiddenInput = document.getElementById("shortUrl");
  hiddenInput.style.display = 'block';
  hiddenInput.select();
  document.execCommand("copy");
  hiddenInput.style.display = 'none';
  var copybtn = document.getElementById("copyurlbutton");
  copybtn.style.text = '#FFFFFF';
  copybtn.style.backgroundColor = '#44B174';
  copybtn.classList.remove("btn-secondary");
  copybtn.classList.add("btn-primary");
  copybtn.innerHTML = "Copied!";
  return false;
}


Paloma.controller('Leaderboards', {
  index: function(){
    pauseAndPlay();
  },
  show: function(){
    pauseAndPlay();
  }
});
