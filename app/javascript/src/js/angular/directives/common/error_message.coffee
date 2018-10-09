# Displays a shared template for rendering an error message
# See usage in templates, example:
# %error-message{'visible'=>'{{hasError}}', 'message'=>"Unable to load the things"}

@gradecraft.directive 'errorMessage', [()->
  {
    scope:
      visible: '='
      message: '@'
    templateUrl: 'common/error_message.html'
  }
]
