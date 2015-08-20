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
    var badgeSelector = parent.find('#badges-list');
    var val = $(select).val();
    if(val === 'Assignment') {
      assignmentSelector.show();
      badgeSelector.hide();
      assignmentSelector.find('input').each(function(i, input){
        $(input).prop('disabled', false);
      });
      badgeSelector.find('input').each(function(i, input){
        $(input).prop('disabled', true);
      });
    } else if(val === 'Badge') {
      assignmentSelector.hide();
      badgeSelector.show();
      badgeSelector.find('input').each(function(i, input){
        $(input).prop('disabled', false);
      });
      assignmentSelector.find('input').each(function(i, input){
        $(input).prop('disabled', true);
      });
    } else {
      var allFields = [assignmentSelector, badgeSelector];
      assignmentSelector.hide();
      badgeSelector.hide();
      $.each(allFields, function(i, group){
        group.find('input').each(function(i, input){
          $(input).prop('disabled', true);
        });
      });
    }
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
