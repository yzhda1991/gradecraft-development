// require spec_helper

"use strict";

describe('GradeService', function() {

  var GradeService = null;
  beforeEach(inject(function(_GradeService_) {
    GradeService = _GradeService_;
  }))
  it('Should define methods', function() {
    expect(GradeService.getGrade).toBeDefined()
    expect(GradeService.getGrade).toEqual(jasmine.any(Function))
  });
});
