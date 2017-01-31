#= require spec_helper

# resource: https://nathanleclaire.com/blog/2014/04/12/unit-testing-services-in-angularjs-for-fun-and-for-profit/
describe 'GradeService', ()->

  response = {
    data: {
      type: "grades",
      id: "101",
      attributes: {
        id: 101,
        feedback: "great jorb!"
      }
    },
    meta: {
      grade_status_options: ["In Progress", "Graded"],
      threshold_points: 100
    }
  }

  beforeEach inject (_GradeService_) ->
    @GradeService = _GradeService_

  describe 'getGrade', ()->
    it 'Should load the grade', ()->
      @http.whenGET("/api/assignments/1/students/2/grade/").respond(response)
      @GradeService.getGrade(1, "student", 2)
      @http.flush()
      expect(@GradeService.grade.id).toEqual(101)

    it 'Should load the options for grade status', ()->
        @http.whenGET("/api/assignments/1/students/2/grade/").respond(response)
        @GradeService.getGrade(1, "student", 2)
        @http.flush()
        expect(@GradeService.gradeStatusOptions).toEqual(["In Progress", "Graded"])



