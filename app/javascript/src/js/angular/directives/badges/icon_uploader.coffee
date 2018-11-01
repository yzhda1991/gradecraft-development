gradecraft.directive 'badgeIconUploader', ['BadgeService', (BadgeService) ->

  return {
    scope: {
      badge: "="
    }
    templateUrl: 'badges/icon_uploader.html',
    link: (scope, element, attrs)->
      scope.fileUploads = BadgeService.fileUploads

      scope.removeIcon = ()->
        BadgeService.removeIcon(@badge.id)

      scope.deleteFile = (file)->
        BadgeService.deleteFileUpload(file)
  }
]

gradecraft.directive('badgeIconUpload', ['$parse', 'BadgeService', ($parse, BadgeService)->
  return {
    restrict: 'A',
    scope: {
      badgeId : "="
    }
    link: (scope, element, attrs)->
      model = $parse(attrs.badgeIconUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          BadgeService.postIconUpload(scope.badgeId, element[0].files)
        )
      )
    }
])

gradecraft.directive('badgeFileUpload', ['$parse', 'BadgeService', ($parse, BadgeService)->
  return {
    restrict: 'A',
    scope: {
      badgeId : "="
    }
    link: (scope, element, attrs)->
      model = $parse(attrs.badgeFileUpload)

      element.bind('change', ()->
        scope.$apply(()->
          model.assign(scope, element[0].files)
          BadgeService.postFileUploads(scope.badgeId, element[0].files)
        )
      )
    }
])

