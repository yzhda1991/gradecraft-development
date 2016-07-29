/** Course search utility for admin **/

!function(app, $) {
  $(document).ready(function() {
    if($('.courses-search-query').length) {
      var target = $('.courses-search-query');
      $.ajax({
        url: target.data('autocompleteurl'),
        dataType: "json",
        success: function(courses) {
          target.omniselect({
            source: courses,
            resultsClass: 'typeahead dropdown-menu course-result',
            activeClass: 'active',
            itemLabel: function(course) {
              return course.course_number + " " + course.name +
                " (" + course.semester + " " + course.year + ")";
            },
            itemId: function(course) {
              return course.id;
            },
            renderItem: function(label) {
              return '<li><a href="#">' + label + '</a></li>';
            },
            filter: function(item, query) {
              var regex = new RegExp(query, 'i');
              return item.name.match(regex) || item.course_number.match(regex);
            }
          }).on('omniselect:select', function(event, id) {
            window.location = "/current_course/change?course_id=" + id
            return false;
          });
        }
      });
    }
  });
}(Gradecraft, jQuery);
