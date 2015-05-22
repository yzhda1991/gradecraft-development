!function($) {
  var init = function() {
    var hill_positions = _.shuffle([1,2,3]);
    $('.hill').each(function(i, hill){
      $(hill).addClass("hill-position-" + hill_positions[i]).addClass("popup").removeClass("hidden");
    });
    $('.hill-fill').addClass("swellup").removeClass("hidden");
    var mountain_sizes = _.shuffle([1,2,3,4,5,1,2,3,4,5]);
    $('.mountain').each(function(i, mountain){
      $(mountain).addClass("mountain-size-" + mountain_sizes[i]).addClass("popup").removeClass("hidden");
    });
    var bubble_sizes = _.shuffle([1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12])
    $('.cloud-bubble').each(function(i, cloud){
      $(cloud).addClass("cloud-bubble-" + bubble_sizes[i])
    })
  };
  $(init);
}(jQuery);

