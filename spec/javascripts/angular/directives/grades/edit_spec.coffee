#= require spec_helper

describe 'gradeEdit directive', ()->

  beforeEach ()->
    @http.whenGET("/api/assignments/1").respond(apiTestDoubles.assignment.standard)
    @http.whenGET("/api/assignments/1/students/99/grade/").respond(apiTestDoubles.grade.standard)
    @http.whenGET("/api/badges").respond({})


  it 'loads the edit template', ()->
    element = @compile("<grade-edit assignment-id=1 recipient-type=student recipient-id=99 ></grade-edit>")(@rootScope)
    @rootScope.$digest()
    expect($(element).children("loading-message")).toBeDefined();
    expect($(element).children("article.grade-form-fields")).toBeDefined();
    expect($(element).children("grade-status-select")).toBeDefined();
    expect($(element).children("grade-submit-buttons")).toBeDefined();
    expect($(element).children("grade-last-updated")).toBeDefined();
