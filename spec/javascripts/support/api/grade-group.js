var apiTestDoubles = apiTestDoubles === undefined ? {} : apiTestDoubles;
apiTestDoubles.grade = apiTestDoubles.grade === undefined ? {} : apiTestDoubles.grade;

apiTestDoubles.grade.group =
{
  "data": [
    {
      "type": "grades",
      "id": "1610",
      "attributes": {
        "id": 1610,
        "assignment_id": 2,
        "student_id": 10,
        "group_id": 101,
        "feedback": "",
        "status": "Graded",
        "raw_points": 1000,
        "pass_fail_status": null,
        "adjustment_points": -100,
        "final_points": 900,
        "adjustment_points_feedback": null,
        "updated_at": "2017-02-09T14:58:57.004-05:00"
      }
    },
    {
      "type": "grades",
      "id": "1608",
      "attributes": {
        "id": 1608,
        "assignment_id": 2,
        "student_id": 16,
        "group_id": 101,
        "feedback": "",
        "status": "Graded",
        "raw_points": 1000,
        "pass_fail_status": null,
        "adjustment_points": -100,
        "final_points": 900,
        "adjustment_points_feedback": null,
        "updated_at": "2017-02-09T14:58:56.945-05:00"
      }
    },
    {
      "type": "grades",
      "id": "1609",
      "attributes": {
        "id": 1609,
        "assignment_id": 2,
        "student_id": 22,
        "group_id": 101,
        "feedback": "",
        "status": "Graded",
        "raw_points": 1000,
        "pass_fail_status": null,
        "adjustment_points": -100,
        "final_points": 900,
        "adjustment_points_feedback": null,
        "updated_at": "2017-02-09T14:58:56.976-05:00"
      }
    }
  ],
  "meta": {
    "student_ids": [
      22,
      16,
      10
    ],
    "grade_status_options": [
      "In Progress",
      "Graded",
      "Released"
    ],
    "threshold_points": 0,
    "is_rubric_graded": false
  }
}
