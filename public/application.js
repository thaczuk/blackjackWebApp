$(document).ready(function(){
  player_hit();
  player_stay();
});

function player_hit() {
  $(document).on("click", "form#hit_form", function() {
    $.ajax({
      type: 'POST',
      url: '/hit'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function player_stay() {
  $(document).on("click", "form#stay_form", function() {
    $.ajax({
      type: 'POST',
      url: '/stay'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

