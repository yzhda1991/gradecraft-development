/** Course search utility for admin **/
!function(app, $) {
  $(document).ready(function() {
    if($('.courses-search-query').length) {
      var target = $('.courses-search-query');
      $.ajax({
        url: target.data('autocompleteurl'),
        dataType: "json",
        success: function(response) {
          target.omniselect({
            source: response.data,
            resultsClass: 'typeahead dropdown-menu course-result',
            activeClass: 'active',
            itemLabel: function(course) {
              return course.attributes.formatted_name;
            },
            itemId: function(course) {
              return course.attributes.id;
            },
            renderItem: function(label) {
              return '<li><a href="#">' + label + '</a></li>';
            },
            filter: function(course, query) {
              return course.attributes.search_string.match(new RegExp(query, 'i'));
            }
          }).on('omniselect:select', function(event, id) {
            window.location = "/courses/" + id + "/change"
            return false;
          });
        }
      });
    }
  });
}(Gradecraft, jQuery);
