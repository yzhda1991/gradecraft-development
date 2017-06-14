var apiTestDoubles = apiTestDoubles === undefined ? {} : apiTestDoubles ;
apiTestDoubles.grade = apiTestDoubles.grade === undefined ? {} : apiTestDoubles.grade ;


apiTestDoubles.grade.withAttachment =
{
  "data": {
    "type": "grades",
    "id": "1234",
    "attributes": {
      "id": 1235,
      "assignment_id": 1,
      "student_id": 99,
      "group_id": null,
      "feedback": "",
      "status": null,
      "raw_points": 1000,
      "pass_fail_status": null,
      "adjustment_points": -100,
      "final_points": null,
      "adjustment_points_feedback": "because yer late",
      "updated_at": "2017-02-08T14:04:57.922-05:00"
    },
    "relationships": {
      "file_uploads": {
        "data": [
          {
            "type": "file_uploads",
            "id": "5"
          }
        ]
      }
    }
  },
  "included": [
    {
      "type": "file_uploads",
      "id": "555",
      "attributes": {
        "id": 555,
        "grade_id": 1235,
        "filename": "image.jpg",
        "filepath": null
      }
    }
  ],
  "meta": {
    "threshold_points": 0,
    "is_rubric_graded": true
  }
}
