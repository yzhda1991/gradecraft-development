var apiTestDoubles = apiTestDoubles === undefined ? {} : apiTestDoubles ;
apiTestDoubles.grade = apiTestDoubles.grade === undefined ? {} : apiTestDoubles.grade ;


apiTestDoubles.grade.withRubric =
{
  "data": {
    "type": "grades",
    "id": "516",
    "attributes": {
      "id": 516,
      "assignment_id": 71,
      "student_id": 99,
      "group_id": null,
      "feedback": "As Aristotle said, <strong>\"The whole is greater than the sum of its parts.\"</strong>",
      "status": "Graded",
      "raw_points": 410000,
      "pass_fail_status": null,
      "adjustment_points": 0,
      "final_points": 410000,
      "adjustment_points_feedback": null,
      "updated_at": "2017-01-26T11:08:59.734-05:00"
    },
    "relationships": {
      "criterion_grades": {
        "data": [
          {
            "type": "criterion_grades",
            "id": "76"
          },
          {
            "type": "criterion_grades",
            "id": "77"
          },
          {
            "type": "criterion_grades",
            "id": "78"
          },
          {
            "type": "criterion_grades",
            "id": "79"
          },
          {
            "type": "criterion_grades",
            "id": "80"
          }
        ]
      }
    }
  },
  "included": [
    {
      "type": "criterion_grades",
      "id": "76",
      "attributes": {
        "id": 76,
        "grade_id": 516,
        "assignment_id": 71,
        "points": 90000,
        "criterion_id": 51,
        "level_id": 351,
        "student_id": 99,
        "comments": "good work Reynard the Fox!"
      }
    },
    {
      "type": "criterion_grades",
      "id": "77",
      "attributes": {
        "id": 77,
        "grade_id": 516,
        "assignment_id": 71,
        "points": 50000,
        "criterion_id": 52,
        "level_id": 358,
        "student_id": 99,
        "comments": "good work Reynard the Fox!"
      }
    },
    {
      "type": "criterion_grades",
      "id": "78",
      "attributes": {
        "id": 78,
        "grade_id": 516,
        "assignment_id": 71,
        "points": 100000,
        "criterion_id": 53,
        "level_id": 365,
        "student_id": 99,
        "comments": "good work Reynard the Fox!"
      }
    },
    {
      "type": "criterion_grades",
      "id": "79",
      "attributes": {
        "id": 79,
        "grade_id": 516,
        "assignment_id": 71,
        "points": 70000,
        "criterion_id": 54,
        "level_id": 372,
        "student_id": 99,
        "comments": "good work Reynard the Fox!"
      }
    },
    {
      "type": "criterion_grades",
      "id": "80",
      "attributes": {
        "id": 80,
        "grade_id": 516,
        "assignment_id": 71,
        "points": 100000,
        "criterion_id": 55,
        "level_id": 379,
        "student_id": 99,
        "comments": "good work Reynard the Fox!"
      }
    }
  ],
  "meta": {
    "grade_status_options": [
      "In Progress",
      "Graded",
      "Released"
    ],
    "threshold_points": 0,
    "is_rubric_graded": true
  }
}
