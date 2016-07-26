//Toggle public page mobile menu
$(".btn-public-nav").click(function(){
    $(".public-nav").slideToggle();
});

function animateMobileMenu() {
  var $offscreenSidebar = $('.offscreen-sidebar');
  var $contentMask = $('.nav-flyout-contentmask');
  var $body = $('body');
  var transitionEnd = 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend';

  $offscreenSidebar.addClass('animating');
  if ($offscreenSidebar.hasClass('menu-visible')) {
    $offscreenSidebar.addClass('closing');
  } else {
    $offscreenSidebar.addClass('opening');
  }

  $offscreenSidebar.on(transitionEnd, function() {
    $offscreenSidebar
      .removeClass('animating closing opening')
      .toggleClass('menu-visible');
   
    $offscreenSidebar.off(transitionEnd);
  });

  $contentMask.toggle();
  $body.toggleClass("noscroll");  
}

//Toggle in-app mobile menu
$(".btn-navbar-left, .nav-flyout-contentmask").click(function() {
  animateMobileMenu();
});

// course switcher in mobile nav
$(".course-switcher-btn").click(function(){
    $(".course-list-container, .course-switcher-btn").toggleClass("open");
    $(".mobile-menu-content").toggle();
});

// course info accordion in mobile nav
$(".course-info-btn-mobile").click(function(){
    $(".course-info, .course-info-btn-mobile").toggleClass("open");
});