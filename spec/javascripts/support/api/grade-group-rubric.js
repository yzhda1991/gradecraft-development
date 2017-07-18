var apiTestDoubles = apiTestDoubles === undefined ? {} : apiTestDoubles;
apiTestDoubles.grade = apiTestDoubles.grade === undefined ? {} : apiTestDoubles.grade;

apiTestDoubles.grade.groupRubric =
{
  "data": [
    {
      "type": "grades",
      "id": "1622",
      "attributes": {
        "id": 1622,
        "assignment_id": 96,
        "student_id": 7,
        "group_id": 3,
        "feedback": "",
        "status": "Graded",
        "raw_points": 227000,
        "pass_fail_status": null,
        "adjustment_points": 8000,
        "final_points": 235000,
        "adjustment_points_feedback": "<p>And some text here...</p>",
        "updated_at": "2017-01-26T14:49:16.878-05:00"
      },
      "relationships": {
        "criterion_grades": {
          "data": [
            {
              "type": "criterion_grades",
              "id": "514"
            },
            {
              "type": "criterion_grades",
              "id": "517"
            },
            {
              "type": "criterion_grades",
              "id": "520"
            },
            {
              "type": "criterion_grades",
              "id": "511"
            },
            {
              "type": "criterion_grades",
              "id": "508"
            }
          ]
        }
      }
    },
    {
      "type": "grades",
      "id": "1620",
      "attributes": {
        "id": 1620,
        "assignment_id": 96,
        "student_id": 13,
        "group_id": 3,
        "feedback": "",
        "status": "Graded",
        "raw_points": 222000,
        "pass_fail_status": null,
        "adjustment_points": 8000,
        "final_points": 230000,
        "adjustment_points_feedback": "<p>And some text here...</p>",
        "updated_at": "2017-01-26T14:48:58.548-05:00"
      },
      "relationships": {
        "criterion_grades": {
          "data": [
            {
              "type": "criterion_grades",
              "id": "512"
            },
            {
              "type": "criterion_grades",
              "id": "515"
            },
            {
              "type": "criterion_grades",
              "id": "518"
            },
            {
              "type": "criterion_grades",
              "id": "506"
            },
            {
              "type": "criterion_grades",
              "id": "509"
            }
          ]
        }
      }
    },
    {
      "type": "grades",
      "id": "1621",
      "attributes": {
        "id": 1621,
        "assignment_id": 96,
        "student_id": 19,
        "group_id": 3,
        "feedback": "",
        "status": "Graded",
        "raw_points": 222000,
        "pass_fail_status": null,
        "adjustment_points": 8000,
        "final_points": 230000,
        "adjustment_points_feedback": "<p>And some text here...</p>",
        "updated_at": "2017-01-26T14:48:58.721-05:00"
      },
      "relationships": {
        "criterion_grades": {
          "data": [
            {
              "type": "criterion_grades",
              "id": "513"
            },
            {
              "type": "criterion_grades",
              "id": "516"
            },
            {
              "type": "criterion_grades",
              "id": "519"
            },
            {
              "type": "criterion_grades",
              "id": "507"
            },
            {
              "type": "criterion_grades",
              "id": "510"
            }
          ]
        }
      }
    }
  ],
  "included": [
    {
      "type": "criterion_grades",
      "id": "512",
      "attributes": {
        "id": 512,
        "grade_id": 1620,
        "assignment_id": 96,
        "points": 6000,
        "criterion_id": 78,
        "level_id": 545,
        "student_id": 13,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "513",
      "attributes": {
        "id": 513,
        "grade_id": 1621,
        "assignment_id": 96,
        "points": 6000,
        "criterion_id": 78,
        "level_id": 545,
        "student_id": 19,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "514",
      "attributes": {
        "id": 514,
        "grade_id": 1622,
        "assignment_id": 96,
        "points": 6000,
        "criterion_id": 78,
        "level_id": 545,
        "student_id": 7,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "515",
      "attributes": {
        "id": 515,
        "grade_id": 1620,
        "assignment_id": 96,
        "points": 57000,
        "criterion_id": 79,
        "level_id": 551,
        "student_id": 13,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "516",
      "attributes": {
        "id": 516,
        "grade_id": 1621,
        "assignment_id": 96,
        "points": 57000,
        "criterion_id": 79,
        "level_id": 551,
        "student_id": 19,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "517",
      "attributes": {
        "id": 517,
        "grade_id": 1622,
        "assignment_id": 96,
        "points": 57000,
        "criterion_id": 79,
        "level_id": 551,
        "student_id": 7,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "518",
      "attributes": {
        "id": 518,
        "grade_id": 1620,
        "assignment_id": 96,
        "points": 48000,
        "criterion_id": 80,
        "level_id": 557,
        "student_id": 13,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "519",
      "attributes": {
        "id": 519,
        "grade_id": 1621,
        "assignment_id": 96,
        "points": 48000,
        "criterion_id": 80,
        "level_id": 557,
        "student_id": 19,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "520",
      "attributes": {
        "id": 520,
        "grade_id": 1622,
        "assignment_id": 96,
        "points": 48000,
        "criterion_id": 80,
        "level_id": 557,
        "student_id": 7,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "506",
      "attributes": {
        "id": 506,
        "grade_id": 1620,
        "assignment_id": 96,
        "points": 75000,
        "criterion_id": 76,
        "level_id": 532,
        "student_id": 13,
        "comments": "<p>caballi</p>"
      }
    },
    {
      "type": "criterion_grades",
      "id": "507",
      "attributes": {
        "id": 507,
        "grade_id": 1621,
        "assignment_id": 96,
        "points": 75000,
        "criterion_id": 76,
        "level_id": 532,
        "student_id": 19,
        "comments": "<p>caballi</p>"
      }
    },
    {
      "type": "criterion_grades",
      "id": "509",
      "attributes": {
        "id": 509,
        "grade_id": 1620,
        "assignment_id": 96,
        "points": 36000,
        "criterion_id": 77,
        "level_id": 538,
        "student_id": 13,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "510",
      "attributes": {
        "id": 510,
        "grade_id": 1621,
        "assignment_id": 96,
        "points": 36000,
        "criterion_id": 77,
        "level_id": 538,
        "student_id": 19,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "511",
      "attributes": {
        "id": 511,
        "grade_id": 1622,
        "assignment_id": 96,
        "points": 36000,
        "criterion_id": 77,
        "level_id": 538,
        "student_id": 7,
        "comments": null
      }
    },
    {
      "type": "criterion_grades",
      "id": "508",
      "attributes": {
        "id": 508,
        "grade_id": 1622,
        "assignment_id": 96,
        "points": 80000,
        "criterion_id": 76,
        "level_id": 526,
        "student_id": 7,
        "comments": "<p>caballi</p>"
      }
    }
  ],
  "meta": {
    "student_ids": [
      19,
      13,
      7
    ],
    "threshold_points": 0,
    "is_rubric_graded": true
  }
}
