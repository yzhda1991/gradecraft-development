!function($) {
  var $document = $(document), $link, selector;

  var init = function() {
    $document = $(document);
    $document.on('click', '.add-assignment-rubric a', addAssignmentRubric);
    $document.on('click', '.remove-assignment-rubric', removeAssignmentRubric);
    findExistingConditions();
  };

  var addAssignmentRubric = function(e) {
    $link = $(this), selector = $link.attr('href');
    $(selector).removeClass('hidden').find('input.destroy').val(false);
    $link.closest('li').addClass('disabled');
    e.preventDefault();
  };

  var removeAssignmentRubric = function() {
    $link = $(this), selector = $link.attr('href');
    $(selector).addClass('hidden');
    $link.prev('input.destroy').val(true);
    $('.add-assignment-rubric a[href="' + selector + '"]').closest('li').removeClass('disabled');
    return false;
  };

  $('.add-unlock-condition').click(function(){
    setTimeout(function() {
      $('.assignment-or-badge:last').change(function(){
          checkDropdown($(this).find('select'));
      });
    }, 500);
  });

  function findExistingConditions() {
    var selects = $('.conditions').find('.assignment-or-badge');
    $.each(selects, function(i, element){
      var select = $(element).find('select');
      checkDropdown(select);
      existingSelectsListener(select);
    });
  }

  function existingSelectsListener(select) {
    $(select).closest('.assignment-or-badge').change(function(){
      checkDropdown($(this).find('select'));
    });
  }

  function checkDropdown(select) {
    var parent = $(select).closest('.conditions');
    var assignmentSelector = parent.find('#assignments-list');
    var assignmentTypeSelector = parent.find('#assignment-types-list');
    var badgeSelector = parent.find('#badges-list');
    var courseSelector = parent.find('#courses-list');
    var val = $(select).val();
    if(val === 'AssignmentType') {
      assignmentSelector.hide();
      assignmentTypeSelector.show();
      badgeSelector.hide();
      courseSelector.hide();
      assignmentTypeSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', false);
      });
      badgeSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      assignmentSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      courseSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
    } else if(val === 'Assignment') {
      assignmentSelector.show();
      assignmentTypeSelector.hide();
      badgeSelector.hide();
      courseSelector.hide();
      assignmentSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', false);
      });
      assignmentTypeSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      badgeSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      courseSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
    } else if(val === 'Badge') {
      assignmentSelector.hide();
      assignmentTypeSelector.hide();
      badgeSelector.show();
      courseSelector.hide();
      badgeSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', false);
      });
      assignmentSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      assignmentTypeSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      courseSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
    } else if(val === 'Course') {
      assignmentSelector.hide();
      assignmentTypeSelector.hide();
      badgeSelector.hide();
      badgeSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      assignmentSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      assignmentTypeSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', true);
      });
      courseSelector.show();
      courseSelector.find('select, input').each(function(i, input){
        $(input).attr('disabled', false);
      });
    } else {
      var allFields = [assignmentSelector, assignmentTypeSelector, badgeSelector, courseSelector];
      assignmentSelector.hide();
      assignmentTypeSelector.hide();
      badgeSelector.hide();
      courseSelector.show();
      $.each(allFields, function(i, group){
        group.find('select, input').each(function(i, input){
          $(input).prop('disabled', true);
        });
      });
    }
  }

  $(init);
}(jQuery);

//Show and hide conditional form items (used on assignment and badge edit)
function showConditionalOptions($thisInput) {
  var $thisConditionalOptionsList = $thisInput.closest('.form-item-with-options').next('.conditional-options');
  
  if ($thisInput.is(':checked')) {
    $thisConditionalOptionsList.show();
  } else {
    $thisConditionalOptionsList.hide();
  }
}

$('input.has-conditional-options').change(function() {
  showConditionalOptions($(this));
});

$('input.has-conditional-options').each(function() {
  showConditionalOptions($(this));
});

// for student rubric feedback tab panels
$('ul.level-tabs li').click(function(){
  var criterionId = $(this).parent().parent().attr('id');
  var tabId = $(this).attr('data-tab');

    $('#' + criterionId + ' ul.level-tabs li').removeClass('selected');
    $('#' + criterionId + ' ul.level-tabs li').attr('aria-selected', 'false');
    $('#' + criterionId + ' .tab-panel').removeClass('selected');
    $('#' + criterionId + ' .tab-panel').attr('aria-selected', 'false');

    $(this).addClass('selected');
    $(this).attr('aria-selected', 'true');
    $("#" + tabId).addClass('selected');
    $("#" + tabId).attr('aria-selected', 'true');
  })

// toggle class analytics on rubric feedback
$('#class-analytics-toggle').change(function(){
  if ($(this).prop("checked")) {
    $('.graded-students').show();
  } else {
    $('.graded-students').hide();
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
