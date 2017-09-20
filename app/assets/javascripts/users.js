!function(app, $) {
  $(document).ready(function() {
    if($('.students-search-query').length) {
      var target = $('.students-search-query');
      $.ajax({
        url: target.data('autocompleteurl'),
        dataType: "json",
        success: function(users) {
          target.omniselect({
            source: users,
            resultsClass: 'typeahead dropdown-menu student-result',
            activeClass: 'active',
            itemLabel: function(user) {
              return user.name;
            },
            itemId: function(user) {
              return user.id;
            },
            renderItem: function(label) {
              return '<li><a href="#">' + label + '</a></li>';
            },
            filter: function(item, query) {
              return item.search_string.match(new RegExp(query, 'i'));
            }
          }).on('omniselect:select', function(event, id) {
            window.location = '/students/' + id;
            return false;
          });
        }
      });
    }
  });
}(Gradecraft, jQuery);
