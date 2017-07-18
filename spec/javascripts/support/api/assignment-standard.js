var apiTestDoubles = apiTestDoubles === undefined ? {} : apiTestDoubles;
apiTestDoubles.assignment = apiTestDoubles.assignment === undefined ? {} : apiTestDoubles.assignment;

apiTestDoubles.assignment.standard =
{
  "data": {
    "type": "assignments",
    "id": "1",
    "attributes": {
      "accepts_submissions_until": null,
      "assignment_type_id": 1,
      "description": "A Stardard Assignment",
      "due_at": "2017-02-02T11:08:27.966-05:00",
      "full_points": 5000,
      "id": 1,
      "name": "Standard Assignment",
      "pass_fail": false,
      "position": 2,
      "purpose": "For testing api/assignments/1",
      "threshold_points": 0,
      "has_info": true,
      "has_levels": false,
      "has_threshold": false,
      "is_a_condition": false,
      "is_due_in_future": false,
      "is_earned_by_group": false,
      "is_required": false,
      "is_rubric_graded": true,
      "is_locked": false,
      "has_been_unlocked": false,
      "has_submission": false,
      "is_accepting_submissions": false,
      "is_late": false,
      "is_closed_without_submission": false
    }
  },
  "meta": {
    "term_for_assignment": "Assignment",
    "term_for_pass": "Pass",
    "term_for_fail": "Fail"
  }
}
