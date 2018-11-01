# Displays "Loading..." icon with custom message while Angular app is loading
# See usage in templates, example:
# %loading-message{'loading'=>'loading', 'message'=>"Loading Badges..."}

gradecraft.directive 'loadingMessage', [()->

  return {
    scope: {
      loading: '=',
      message: '@'
    }
    templateUrl: 'loading_message.html'
  }
]
