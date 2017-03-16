# Pass / Fail Assignments

Pass/Fail assignments are zero-point based assignments. It should be noted that the terms "Pass" and "Fail" can be configured on a per-course basis, see [[customized terms]]. For clarity, the naming convention 'pass_fail' was maintained throughout the code base, but it is recommended that professors come up with another term for "Fail" as studies show this word is demotivating.

### Pass/Fail Models

#### Assignment

  * `pass_fail` - boolean switch which manages all pass fail logic. Verified with `assignment.pass_fail?`
  * `full_points` - set to 0

#### Grade

Grades for pass fail assignments have a before save function in the Grade and Assignment models that makes sure all points remain 0.

  * `pass_fail_status` : initially nil, string that is set to "Pass" and "Fail" when graded
  * `raw_points` - set to 0
  * `predicted_score` - set to 1 for a predicted pass or 0 as a fail
  * `final_points`- set to 0
  * `full_points` - reflects (and inherits from) the assignment - stays 0
  * `status` - maintains normal behavior (reflects state in grading process)

## Customized Terms

Both 'pass' and 'fail' can be customized at the course level. See [[customized terms]] for more info.

### TODO:

Pass/fail assignments as a way to unlock pathways to other assignments.
