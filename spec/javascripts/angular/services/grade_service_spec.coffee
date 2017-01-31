#= require spec_helper

describe 'GradeService', ()->

  beforeEach inject (_GradeService_) ->
    @GradeService = _GradeService_

  it 'Should define methods', ()->
    expect(@GradeService.getGrade).toBeDefined()
    expect(@GradeService.getGrade).toEqual(jasmine.any(Function))
