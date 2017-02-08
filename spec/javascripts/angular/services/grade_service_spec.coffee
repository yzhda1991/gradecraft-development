#= require spec_helper

# resource: https://nathanleclaire.com/blog/2014/04/12/unit-testing-services-in-angularjs-for-fun-and-for-profit/
describe 'GradeService', ()->

  beforeEach inject (_GradeService_, _DebounceQueue_) ->
    @GradeService = _GradeService_
    @DebounceQueue = _DebounceQueue_

  describe 'getGrade', ()->
    beforeEach ()->
      @http.whenGET("/api/assignments/1/students/99/grade/").respond(apiTestDoubles.grade.new)
      @GradeService.getGrade(1, "student", 99)
      @http.flush()

    it 'should load the grade', ()->
      expect(@GradeService.grade.id).toEqual(1234)

    it 'should load the options for grade status', ()->
      expect(@GradeService.gradeStatusOptions).toEqual(["In Progress", "Graded"])

  describe 'queueUpdateGrade', ()->
    beforeEach ()->
      @DebounceQueue.addEvent = @testdouble.function('DebounceQueue')

    it 'should queue a call to update', ()->
      @GradeService.queueUpdateGrade()
      expect().toVerify(@DebounceQueue.addEvent(), {ignoreExtraArgs: true})

    it 'should include a recalculation of the grade points', ()->
      #seed the grade by mocking the internal call to get grade
      @http.whenGET('/api/assignments/1/students/99/grade/').respond(apiTestDoubles.grade.withPoints)
      @GradeService.getGrade(1, 'student', 99)
      @http.flush()

      @GradeService.queueUpdateGrade()
      expect(@GradeService.grade.final_points).toEqual(900)

