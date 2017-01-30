//= require angular-mocks

describe('BadgeCtrl', function() {
  beforeEach(module('gradecraft'));

  var $controller;
  var $http;

  beforeEach(inject(function($rootScope, _$httpBackend_, _$controller_){
    $scope = $rootScope.$new()
    $http = _$httpBackend_;
    $controller = _$controller_;
  }));

  describe('$scope.badges', function() {
    it('loads the badges on init', function() {
      var controller = $controller('BadgeCtrl', { $scope: $scope });
      expect($scope.termFor("badges")).toEqual("Badges");
    });

    it('loads the badges via service on init', function() {
      var controller = $controller('BadgeCtrl', { $scope: $scope });
      // Need to mock $scope.services() with:
      //$http.expectGET('/api/badges').respond(201, {data:[{id:"1",type:"badges",attributes:{}}],meta:{term_for_badges:"bingos"}})
      //$http.flush()
      $scope.init();
    })
  });
});

