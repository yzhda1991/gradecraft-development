Here is a rundown of Human Testing for the Grading Form, using standard sample data:

## Test Pass/Fail Grades

- Grade Hannah Abbott's Grade For Pass/Fail  [No Grades]
	- keep Pass/Fail as "Pass"
	- upload a feedback file
	- add text feedback
	- add an earned badge
	- select "Graded" status
	- pause for 3 seconds and refresh page (don't submit)
		- Feedback text and file should be saved
		- Earned Badge should be saved
		- Pass/Fail should still show "Pass"
		- Status should revert to blank
		- submit buttons should be disabled
	- choose "Graded" Status again
		- submit buttons should be enabled
	- click "Submit and Grade Next"
		- you should be redirected to Euan Abercrombie's Grade For Pass/Fail [No Grades]
- Grade Euan Abercrombie's Grade For Pass/Fail  [No Grades]
	- choose Pass/Fail as "Fail"
	- pause for 3 seconds and refresh page (don't submit)
		- Pass/Fail should still show "Fail"
	- choose "In Progress" Status
	- click "Submit"
		- you should be redirected to the Assignment Index Page
- Validate Grades as Instructor
	- Hannah should show as "Pass", "Graded"
	- Euan should show as "Fail", "In Progress"
- Click "See Grade" for Hannah
	- All fields should be shown as submitted
- Click "Edit Grade" for Hannah's grade
	- All field values should still be correct
	- Only a "Submit" button should show below, no "Submit and Grade Next" option

## Test Standard Grading

- Grade Hannah Abbott's " Standard Edit + Quick Grade With Text Box [No Grades]"
	- enter raw points
		- verify final points is equal to raw points
	- enter adjustment points
		- verify the adjustment points feedback field appears
		- verify the final points are calculated correctly
	- enter adjustment points feedback
	- upload a feedback file
	- add feedback text
	- add an earned badge
	- change status from blank to "Graded"
	- pause for 3 seconds and refresh page (don't submit)
		- verify raw points selector shows the level you selected
		- adjustment, and final points should not have changed
		- Feedback and adjustment points feedback should be saved
		- Earned Badge should be saved
		- Status should revert to blank
		- submit buttons should be disabled
	- choose "Graded" Status again
		- submit buttons should be enabled
	- click "Submit and Grade Next"
		- you should be redirected to Euan Abercrombie's "Standard Edit + Quick Grade With Text Box [No Grades]"
	- return to Assignment Index Page
		- verify that the correct score and status are visible

## Test Level Select Grading

- Grade Hannah Abbott's " Assignment With Score Levels [No Grades]"
	- select a level from the selector
		- verify level points selector is blank before selection
		- verify final points is updated after selection
	- enter adjustment points
		- verify the adjustment points feedback field appears
		- verify the final points are calculated correctly
	- enter adjustment points feedback
	- upload a feedback file
	- add feedback text
	- add an earned badge
	- change status from blank to "Graded"
	- pause for 3 seconds and refresh page (don't submit)
		- verify raw points selector shows the level you selected
		- adjustment, and final points should not have changed
		- Feedback and adjustment points feedback should be saved
		- Earned Badge should be saved
		- Status should revert to blank
		- submit buttons should be disabled
	- choose "Graded" Status again
		- submit buttons should be enabled
	- click "Submit and Grade Next"
		- you should be redirected to Euan Abercrombie's "Standard Edit + Quick Grade With Text Box [No Grades]"
	- return to Assignment Index Page
		- verify that the correct level and points are displayed

## Test Thresholds

- Click edit on a grade in the assignment "Points Threshold And Insufficient Grades"
	- verify that the final points are calculated as zero
	- add enough raw points to meet the threshold
		- verify that the final points are the same as the raw points
	- add negative adjustment points to drop score below threshold
		- verify that final points return to zero

## Test Rubric Grading

- Grade Hannah Abbott's " Rubric Graded Assignment [No Grades]"
	- select a levels for the first criteria
		- verify final points is equal to the level points 
	- add feedback to the criteria level
	- pause for 3 seconds and refresh page (don't submit)
		- verify that the level and feedback are still present, and the final points haven't changed
	- Select a level for each criteria, and repeat the refresh test
		- verify that all criteria levels have saved
	- enter adjustment points
		- verify the adjustment points feedback field appears
		- verify the final points are calculated correctly
	- enter adjustment points feedback
	- upload a feedback file
	- add feedback text
	- add an earned badge
	- change status from blank to "Released"
	- pause for 3 seconds and refresh page (don't submit)
		- verify criteria all show the levels you selected
		- adjustment, and final points should not have changed
		- Feedback and adjustment points feedback should be saved
		- Earned Badge should be saved
		- Status should revert to blank
		- submit buttons should be disabled
	- choose "Released" Status again
		- submit buttons should be enabled
	- click "Submit and Grade Next"
		- you should be redirected to Euan Abercrombie's "Rubric Graded Assignment [No Grades]"
	- return to Assignment Index Page
		- You should see the final points haven't changed and the status is "Released"
		- click "See Grade"
			- verify that all grade information is correct

## Test Pass/Fail Grades For Groups

- follow the "Test Pass/Fail Grading" steps for a group on "Pass/Fail Group Assignment"
	- verify that all students have the same grade information stored in their grade
- override one students grade
	- verify that that only that student's grade has changed

## Test Standard Grading For Groups

- follow the "Test Standard Grading" steps for a group on "Standard Edit Group Assignment"
	- verify that all students have the same grade information stored in their grade
- override one students grade
	- verify that that only that student's grade has changed

## Test Level Select Grading For Groups

- follow the "Test Level Select" steps for a group on "Pass/Fail Group Assignment"
	- verify that all students have the same grade information stored in their grade
- override one students grade
	- verify that that only that student's grade has changed

## Test Rubric Grading For Groups

- follow the "Test Rubric Grading" steps for a group on "Rubric Graded Group Assignment"
	- verify that all students have the same grade information stored in their grade
- override one students grade
	- verify that that only that student's grade has changed
