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

  if($('.locked-visibility-options > input').is(':checked')) {
    $('ul > .locked-display').show();
  } else {
    $('ul > .locked-display').hide();
  }

  $('.locked-visibility-options').change(function(){
    if($(this).is(":checked")) {
      $('ul > .locked-display').toggle();
    } else {
      $('ul > .locked-display').toggle();
    }
  });

  if($('.assignment_options > input').is(':checked')) {
    $('ul > .submit').show();
  } else {
    $('ul > .submit').hide();
  }

  $('.assignment_options').change(function(){
    if($(this).is(":checked")) {
      $('ul > .submit').toggle();
    } else {
      $('ul > .submit').toggle();
    }
  });

  $(init);
}(jQuery);

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

// Show only earned level on mobile for rubric grades regardless of previous selection
function rubricScreenSize() {
  if ($('.level-tabs').css('display') === 'none') {
    $('.level-tab.earned').trigger('click');
    $('.tab-panel-container').addClass('mobile-rubric-slider');
  }
}
rubricScreenSize();
$(window).resize(rubricScreenSize);

 // Initialize slick slider on mobile for graded rubrics
$('.mobile-rubric-slider').slick({
  prevArrow: '<a class="fa fa-caret-left previous rubric-slider-button"></a>',
  nextArrow: '<a class="fa fa-caret-right next rubric-slider-button"></a>',
  adaptiveHeight: true, 
  infinite: false
});
