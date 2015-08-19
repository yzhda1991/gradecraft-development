!function($) {
  var $document = $(document), $link, selector;

  $document.ready(function() {
    $('.conditions').find('.assignment-or-badge').each(function(i, select){
      checkDropdown(select);
      checkExistingSelects(select);
    });
  });

  var init = function() {
    $document = $(document);
    $document.on('click', '.add-assignment-rubric a', addAssignmentRubric);
    $document.on('click', '.remove-assignment-rubric', removeAssignmentRubric);
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

  var assignmentSelectors = ['.assignments-list', '.assignment-state', '.assignment-minpoints', '.assignment-condition-state', '.assignment-condition-value'];
  var badgesSelectors = ['.badges-list', '.badge-state', '.badge-earned-count', '.badges-condition-state', '.badges-condition-value'];

  $('.add-unlock-condition').click(function(){
    setTimeout(function() {
      $('.assignment-or-badge:last').change(function(){
          checkDropdown($(this).find('select'));
      });
    }, 500);
  });

  // function checkAssignmentBadgeSelects() {
  //   setTimeout(function() {
  //     $('.assignment-or-badge:last').change(function(){
  //         checkDropdown($(this).find('select'));
  //     });
  //   }, 500);
  // }

  function checkDropdown(select) {
    //debugger;
    var parent = $(select.parentNode.parentNode);
    var val = $(select).val();
    if(val === 'Assignment') {
      if(parent.find('.badges-list').is(':visible')) {
        toggleForms(parent, "Badges");
      }
      toggleForms(parent, "Assignments");
    } else if(val === 'Badge') {
      if(parent.find('.assignments-list').is(':visible')) {
        toggleForms(parent, "Assignments");
      }
      toggleForms(parent, "Badges");
    } else {
      toggleForms(parent, "Both");
    }
  }

  function toggleForms(parent, forms) {
    if(forms === "Assignments") {
      $.each(assignmentSelectors, function(i, selector){
        parent.find(selector).toggle();
      });
    } else if(forms === "Badges") {
      $.each(badgesSelectors, function(i, selector){
        parent.find(selector).toggle();
      });
    } else {
      var allFields = $.merge(assignmentSelectors, badgesSelectors);
      $.each(allFields, function(i, selector){
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
