// Matching the main content div to the size of the window
//Initial load of page

$(".make-lizards").dblclick(function() {
  $(".fa").toggleClass("fa-hand-lizard-o");
});

$('.close').click(function() {
    $(".alert-box").slideUp();
});

$( "#tabs" ).tabs({
  event: "click",
  create: function(event, ui) {
    var widget = $(event.target);
    var panel = widget.find(".ui-tabs-panel");
    var activePanelIndex = panel.find(".active").index();
    if (activePanelIndex >= 0) {
      widget.tabs("option", "active", activePanelIndex);
    }
    //sends the user to the right tab if specified through url
    var hash = $.trim( window.location.hash );
    var urlPanelIndex = panel.find(hash).index();
    if (urlPanelIndex >= 0) {
      widget.tabs("option", "active", urlPanelIndex);
    }
  }
});

 $('.froala').froalaEditor({
  key: 'RD4H4B12B7iB6E5C3A4I2I3C8B6B5A4C-11NGNe1IODMGYNSFKV==',
  inlineMode: false,
  heightMin: 200,
  toolbarButtons: [
    'bold', 'italic', 'underline', 'paragraphFormat', 'insertTable', 'formatOL', 'formatUL','align',
    'outdent', 'indent', 'insertLink', 'undo', 'redo', 'clearFormatting', 'image', 'insertVideo', 'html'
  ],
  toolbarButtonsSM: [
    'bold', 'italic', 'underline', 'paragraphFormat', 'insertTable', 'formatOL', 'formatUL','align',
    'outdent', 'indent', 'insertLink', 'undo', 'redo', 'clearFormatting', 'image', 'insertVideo', 'html'
  ],
  toolbarButtonsXS: ['bold', 'italic', 'underline'],
  toolbarButtonsMD: ['bold', 'italic', 'underline', 'paragraphFormat', 'insertTable', 'formatOL', 'formatUL','align',
  'outdent', 'indent', 'insertLink', 'undo', 'redo', 'clearFormatting', 'image', 'insertVideo', 'html']
})

// handle 'select all' buttons, used on release grade forms
$(".select-all").click(function(e){
  var $link = $(this);

  e.preventDefault();
  $link.offsetParent().find('input[type="checkbox"]').prop('checked', 'checked').trigger('change');
});

// handle 'select none' button, used on release grade forms
$(".select-none").click(function(e){
 var $link = $(this);

  e.preventDefault();
  $link.offsetParent().find('input[type="checkbox"]').prop('checked', false).trigger('change');

});

// select all but only within the table
$(".table-select-all").click(function(e){
  var $link = $(this);
  e.preventDefault();
  $link.parents("table").find('input[type="checkbox"]').prop('checked', 'checked').trigger('change');
});

// select none, but only within the table
$(".table-select-none").click(function(e){
  var $link = $(this);
  e.preventDefault();
  $link.parents("table").find('input[type="checkbox"]').prop('checked', false).trigger('change');
});

$(".assignmentType").collapse({
  show: function() {
    // The context of 'this' is applied to
    // the collapsed details in a jQuery wrapper
    this.slideDown(100);
  },
  hide: function() {
    this.slideUp(100);
  },
  accordion: true,
  persist: true
});

$(".collapseSection").collapse({
  show: function() {
    // The context of 'this' is applied to
    // the collapsed details in a jQuery wrapper
    this.slideDown(100);
  },
  hide: function() {
    this.slideUp(100);
  },
  accordion: true,
  persist: true
});

// Select2 Search forms for group creation
$("#group_student_ids").select2({
  placeholder: "Select Students",
  allowClear: true
});

// Select2 Search forms for team creation
$("#team_student_ids").select2({
  placeholder: "Select Students",
  allowClear: true
});

// Select2 Search forms for anything that has a data-behavior of multi-select
$(document).find("[data-behavior~=multi-select]").select2({
  allowClear: true
});


// truncate text
jQuery(function(){
  var minimized_elements = $('p.minimize');

  minimized_elements.each(function(){
    var t = $(this).text();
    if(t.length < 100) return;

    $(this).html(
        t.slice(0,100)+'<span>... </span><a href="#" class="more">More</a>'+
        '<span style="display:none;">'+ t.slice(100,t.length)+' <a href="#" class="less">Less</a></span>'
    );
  });
  $('a.more', minimized_elements).click(function(event){
      event.preventDefault();
      $(this).hide().prev().hide();
      $(this).next().show();
  });
  $('a.less', minimized_elements).click(function(event){
      event.preventDefault();
      $(this).parent().hide().prev().show().prev().show();
  });
});

//toggle change password form on account settings page
$('#update-password').click(function(event) {
  event.preventDefault();
  $('.update-password-form').show().attr('aria-hidden', 'false');
  $(this).hide().attr('aria-hidden', 'true');
  $('.update-password-wrapper').addClass('form-showing');
});

$('#cancel-password-change').click(function(event) {
  event.preventDefault();
  $('#user_password, #user_password_confirmation').val('');
  $('.update-password-form').hide().attr('aria-hidden', 'true');
  $('#update-password').show().attr('aria-hidden', 'false');
  $('.update-password-wrapper').removeClass('form-showing');
});
