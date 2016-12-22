# One "Card" in the predictor that displays an Assignment, Challenge, or Badge
# Manages linking article to details section in student side panel

@gradecraft.directive 'loadingMessage', [()->

  return {
    scope: {
      loading: '=',
      message: '@'
    }
    templateUrl: 'loading_message.html'
  }
]
