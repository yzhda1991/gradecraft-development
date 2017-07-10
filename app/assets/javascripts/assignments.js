// for student rubric feedback tab panels
function showSelectedTab($tab) {
  var tabPanelId = '#' + $tab.attr('aria-controls');
  var $tabPanel = $(tabPanelId);

    // remove selected class from all tabs and assoc. tab panel other than clicked
    $tab.siblings().removeClass('selected').attr('aria-selected', 'false').attr('tabindex', '-1');
    $tabPanel.siblings().removeClass('selected').attr('aria-hidden', 'true');
    // add selected class on clicked tab and associated tab panel
    $tab.addClass('selected').attr('aria-selected', 'true').attr('tabindex', '0');
    $tabPanel.addClass('selected').attr('aria-hidden', 'false');
}

$('ul.level-tabs li').click(function() {
  showSelectedTab($(this));
});

$('ul.level-tabs li').keydown(function(e) {
  var $tab = $(this);
  var $selectedTab = null;
  var $firstTab = $tab.parent().children().first();
  var $lastTab = $tab.parent().children().last();

  if (e.which === 37) {
    if ($tab.is($firstTab)) {
      $selectedTab = $lastTab;
    } else {
      $selectedTab = $tab.prev();
    }
  } else if (e.which === 39) {
    if ($tab.is($lastTab)) {
      $selectedTab = $firstTab;
    } else {
      $selectedTab = $tab.next();
    }
  }

  $selectedTab.focus();
  showSelectedTab($selectedTab);
});

// toggle class analytics on rubric feedback
$('#class-analytics-toggle').change(function(){
  if ($(this).prop("checked")) {
    $('.graded-students').show();
    $('.binary-switch-socket').addClass('on').removeClass('off');
  } else {
    $('.graded-students').hide();
    $('.binary-switch-socket').removeClass('on').addClass('off');
  }
});

// If screen is at mobile size, initialize slider for rubric feedback and destroy it when screen size is larger than mobile
function rubricScreenSize() {
  var $tabPanelContainer = $('.tab-panel-container');
  // rather than testing window size which varies in browser, using MQ to hide level tabs on mobile
  if ($('.level-tabs').css('display') === 'none') {
    // Initialize slick slider on mobile for graded rubrics if not already initialized
    if (!$tabPanelContainer.hasClass('slick-initialized')) {
      $tabPanelContainer.each(function() {
        var $thisSlider = $(this);

        $thisSlider.slick({
          prevArrow: '<a class="fa fa-caret-left previous rubric-slider-button"></a>',
          nextArrow: '<a class="fa fa-caret-right next rubric-slider-button"></a>',
          initialSlide: $thisSlider.data("start-index"),
          adaptiveHeight: true,
          infinite: false
        });
      });
    }
  } else {
    if ($tabPanelContainer.hasClass('slick-initialized')) {
      $tabPanelContainer.slick("unslick");
    }
  }
}
rubricScreenSize();
$(window).resize(rubricScreenSize);
