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
    if(val === 'Assignment Type') {
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
