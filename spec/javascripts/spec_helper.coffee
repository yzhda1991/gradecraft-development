#= require application
#= require angular-mocks
#= require sinon
#= require jasmine-sinon

beforeEach(module('gradecraft'))

# NOTE: I don't know if these are all available in our version of Angular:
beforeEach inject (_$httpBackend_, _$compile_, $rootScope, _$controller_, $location, $injector, $timeout) ->
  @scope = $rootScope.$new()
  @http = _$httpBackend_
  @compile = _$compile_
  @location = $location
  @controller = _$controller_
  @injector = $injector
  @timeout = $timeout
  @model = (name) =>
    @injector.get(name)
  @eventLoop =
    flush: =>
      @scope.$digest()
  @sandbox = sinon.sandbox.create()

afterEach ->
  @http.verifyNoOutstandingExpectation()
  @http.resetExpectations()
