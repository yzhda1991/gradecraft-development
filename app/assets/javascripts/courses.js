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
              return course.courseno + " " + course.name;
            },
            itemId: function(course) {
              return course.id;
            },
            renderItem: function(label) {
              return '<li><a href="#">' + label + '</a></li>';
            },
            filter: function(item, query) {
              var regex = new RegExp(query, 'i');
              return item.name.match(regex) || item.courseno.match(regex);
            }
          }).on('omniselect:select', function(event, id) {
            var form = document.createElement("form");
            form.setAttribute("method", "post");
            form.setAttribute("action", "/current_course/change");
            var field = document.createElement("input");
            field.setAttribute("type", "hidden");
            field.setAttribute("name", "course_id");
            field.setAttribute("value", id);
            form.appendChild(field);
            document.body.appendChild(form);
            form.submit();
            return false;
          });
        }
      });
    }
  });
}(Gradecraft, jQuery);
