var apiTestDoubles = apiTestDoubles === undefined ? {} : apiTestDoubles;
apiTestDoubles.grade = apiTestDoubles.grade === undefined ? {} : apiTestDoubles.grade;

// A fresh grade without any
apiTestDoubles.grade.new =
{
  "data": {
    "type": "grades",
    "id": "1234",
    "attributes": {
      "id": 1234,
      "assignment_id": 1,
      "student_id": 99,
      "group_id": null,
      "feedback": "",
      "status": null,
      "raw_points": null,
      "pass_fail_status": null,
      "adjustment_points": null,
      "final_points": null,
      "adjustment_points_feedback": null,
      "updated_at": new Date().toGMTString(),
    },
  },
  "meta": {
    "grade_status_options": [
      "In Progress",
      "Graded"
    ],
    "threshold_points": 0,
    "is_rubric_graded": false
  }
}


apiTestDoubles.grade.withPoints = (JSON.parse(JSON.stringify(apiTestDoubles.grade.new)));
apiTestDoubles.grade.withPoints.data.attributes.raw_points = 1000;
apiTestDoubles.grade.withPoints.data.attributes.adjustment_points = -100;
