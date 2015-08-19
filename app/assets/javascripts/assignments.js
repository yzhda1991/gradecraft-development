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

  var assignmentSelectors = ['.assignments-list', '.assignment-minpoints', '.assignment-condition-state', '.assignment-condition-value', '.condition-done-by'];
  var badgeSelectors = ['.badges-list', '.badges-condition-state', '.badges-condition-value', '.condition-done-by'];

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
    var val = $(select).val();
    if(val === 'Assignment') {
      toggleForms(parent, "Assignment");
      $.each(badgeSelectors, function(i, selector){
        parent.find(selector).hide();
      });
    } else if(val === 'Badge') {
      if(parent.find('.assignments-list').is(':visible')) {
        toggleForms(parent, "Assignments");
      }
      toggleForms(parent, "Badge");
    } else {
      toggleForms(parent, "Both");
    }
  }

  function toggleForms(parent, forms) {
    if(forms === "Assignment") {
      $.each(assignmentSelectors, function(i, selector){
        parent.find(selector).toggle();
      });
    } else if(forms === "Badge") {
      $.each(badgeSelectors, function(i, selector){
        parent.find(selector).toggle();
      });
    } else {
      var allFields = $.merge(assignmentSelectors, badgeSelectors);
      allFields = $.unique(allFields);
      $.each(allFields, function(i, selector) {
        parent.find(selector).hide();
      });
    }
  }

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
