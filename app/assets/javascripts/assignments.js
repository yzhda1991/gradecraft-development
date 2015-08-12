!function($) {
  var $document = $(document), $link, selector;

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

  $('.add-unlock-condition').click(checkAssignmentBadgeSelects);

  function checkAssignmentBadgeSelects() {
    setTimeout(function() {
      $('.assignment-or-badge:last').change(function(){
        var val = $(this).find('select').val();
        var parent = $(this.parentNode.parentNode);
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
      });
    }, 500);

    function toggleForms(parent, forms) {
      if(forms === "Assignments") {
        parent.find('.assignments-list').toggle();
        parent.find('.assignment-state').toggle();
        parent.find('.assignment-minpoints').toggle();
      } else if(forms === "Badges") {
        parent.find('.badges-list').toggle();
        parent.find('.badge-state').toggle();
        parent.find('.badge-earned-count').toggle();
      } else {
        parent.find('.badges-list').hide();
        parent.find('.badge-state').hide();
        parent.find('.badge-earned-count').hide();
        parent.find('.assignments-list').hide();
        parent.find('.assignment-state').hide();
        parent.find('.assignment-minpoints').hide();
      }
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
