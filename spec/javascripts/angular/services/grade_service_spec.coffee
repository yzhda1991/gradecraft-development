#= require spec_helper

# resource: https://nathanleclaire.com/blog/2014/04/12/unit-testing-services-in-angularjs-for-fun-and-for-profit/
describe 'GradeService', ()->

  beforeEach inject (_GradeService_, _DebounceQueue_) ->
    @GradeService = _GradeService_
    @DebounceQueue = _DebounceQueue_

  describe 'getGrade', ()->
    describe 'for student', ()->
      beforeEach ()->
        @http.whenGET("/api/assignments/1/students/99/grade/").respond(apiTestDoubles.grades.standard)
        @GradeService.getGrade(1, "student", 99)
        @http.flush()

      it 'should load the grade', ()->
        expect(@GradeService.grades[0].id).toEqual(1234)

      it 'should calculate the final points, defaulting to zero', ()->
        expect(@GradeService.grades[0].raw_points).toEqual(0)
        expect(@GradeService.grades[0].adjustment_points).toEqual(0)
        expect(@GradeService.grades[0].final_points).toEqual(0)

    describe 'for student with included models', ()->
      it 'should load the options for grade status', ()->
        @http.whenGET("/api/assignments/1/students/99/grade/").respond(apiTestDoubles.grades.standard)
        @GradeService.getGrade(1, "student", 99)
        @http.flush()
        expect(@GradeService.gradeStatusOptions).toEqual(["In Progress", "Graded"])

      it 'should include attachments', ()->
        @http.whenGET("/api/assignments/1/students/99/grade/").respond(apiTestDoubles.grades.withAttachment)
        @GradeService.getGrade(1, "student", 99)
        @http.flush()
        expect(@GradeService.fileUploads[0].id).toEqual(555)
        expect(@GradeService.fileUploads[0].filename).toEqual('image.jpg')

      it 'should include rubric criteria', ()->
        @http.whenGET("/api/assignments/1/students/99/grade/").respond(apiTestDoubles.grades.withRubric)
        @GradeService.getGrade(1, "student", 99)
        @http.flush()
        expect(@GradeService.criterionGrades.length).toEqual(5)

    describe 'for group', ()->
      beforeEach ()->
        @http.whenGET("/api/assignments/2/groups/101/grades/").respond(apiTestDoubles.grades.group)
        @GradeService.getGrade(2, "group", 101)
        @http.flush()

      it 'should load the grade for the first student', ()->
        expect(@GradeService.grades[0].id).toEqual(1609)

      it 'should copy all the grades (for future functionality)', ()->
        expect(@GradeService.grades.length).toEqual(3)

    describe 'for group with included models', ()->
      it 'should load the options for grade status', ()->
        @http.whenGET("/api/assignments/2/groups/101/grades/").respond(apiTestDoubles.grades.group)
        @GradeService.getGrade(2, "group", 101)
        @http.flush()
        expect(@GradeService.gradeStatusOptions).toEqual(["In Progress", "Graded", "Released"])

      it 'should load criterion grades, filtered to the first student', ()->
        @http.whenGET("/api/assignments/96/groups/3/grades/").respond(apiTestDoubles.grades.groupRubric)
        @GradeService.getGrade(96, "group", 3)
        @http.flush()
        expect(@GradeService.criterionGrades.length).toEqual(5)

  describe 'queueUpdateGrade', ()->
    beforeEach ()->
      @DebounceQueue.addEvent = @testdouble.function('DebounceQueue')

    it 'should queue a call to update', ()->
      @GradeService.queueUpdateGrade()
      expect().toVerify(@DebounceQueue.addEvent(), {ignoreExtraArgs: true})

    it 'should include a recalculation of the grade points', ()->
      #seed the grade by mocking the internal call to get grade
      @http.whenGET('/api/assignments/1/students/99/grade/').respond(apiTestDoubles.grades.withPoints)
      @GradeService.getGrade(1, 'student', 99)
      @http.flush()

      @GradeService.queueUpdateGrade()
      expect(@GradeService.grades[0].final_points).toEqual(900)

