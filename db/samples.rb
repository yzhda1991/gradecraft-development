user_names = ['Ron Weasley','Fred Weasley','Harry Potter','Hermione Granger','Colin Creevey','Seamus Finnigan','Hannah Abbott',
  'Pansy Parkinson','Zacharias Smith','Blaise Zabini', 'Draco Malfoy', 'Dean Thomas', 'Millicent Bulstrode', 'Terry Boot', 'Ernie Macmillan',
  'Roland Abberlay', 'Katie Bell', 'Regulus Black', 'Euan Abercrombie', 'Brandon Angel']

first_course_team_names = ['Harm & Hammer', 'Abusement Park','Silver Woogidy Woogidy Woogidy Snakes','Carpe Ludus','Eduception','Operation Unthinkable','Team Wang','The Carpal Tunnel Crusaders','Pwn Depot']

second_course_team_names = ['Section 1', 'Section 2', 'Section 3', 'Section 4', 'Section 5', 'Section 6', 'Section 7', 'Section 8', 'Section 9', 'Section 10', 'Section 11', 'Section 12', 'Section 13', 'Section 14', 'Section 15', 'Section 16']

third_course_team_names = ['Late Night Information Nation', 'Heisenberg', 'Big Red Dogs', 'Liu Man Group', 'The House that Cliff Built', 'TMI']

first_course_badge_names = ['Creative', 'Inner Eye', 'Patronus Producer','Cheerful Charmer','Invisiblity Cloak','Marauders Map','Lumos','Rune Reader','Tea Leaf Guru','Wizard Chess Grand Master','Green Thumb','Gamekeeper','Seeker','Alchemist','Healer','Parseltongue','House Cup']

second_course_badge_names = ['MINOR: Learning from Mistakes', 'MINOR: Learning from Mistakes', 'MINOR: Halloween Special', 'MINOR: Thanksgiving Special', 'MINOR: Now It is Personal', 'MAJOR: Makeup Much', 'MAJOR: Practice Makes Perfect', 'MAJOR: Combo Platter', 'MINOR: Makeup Some', 'MINOR: Participatory Democrat', 'MINOR: Number One', 'MINOR: Rockstar', 'MINOR: Over-achiever', 'MINOR: Avid Reader', 'MINOR: Nice Save!', 'MINOR: The Nightstalker', 'MINOR: Paragon of Virtue', 'MAJOR: Bad Investment', 'MINOR: Leader of the pack', 'MINOR: Thoughtful Contribution']

first_course_grade_scheme_hash = { [0,600000] => 'F', [600000,649000] => 'D+', [650000,699999] => 'C-', [700000,749999] => 'C', [750000,799999] => 'C+', [800000,849999] => 'B-', [850000,899999] => 'B', [900000,949999] => 'B+', [950000,999999] => 'A-', [1000000,1244999] => 'A', [1245000,1600000] => 'A+'}

first_course_grade_levels = ['Amoeba', 'Sponge', 'Roundworm', 'Jellyfish', 'Leech', 'Snail', 'Sea Slug', 'Fruit Fly', 'Lobster', 'Ant', 'Honey Bee', 'Cockroach', 'Frog', 'Mouse', 'Rat', 'Octopus', 'Cat', 'Chimpanzee', 'Elephant', 'Human', 'Orca']

third_course_grade_scheme_hash = { [0,600000] => 'E', [600000,629999] => 'D-', [630000,669999] => 'D', [670000,699999] => 'D+', [700000,729999] => 'C-', [730000,769999] => 'C', [770000,799999] => 'C+', [800000,829999] => 'B-', [830000,869999] => 'B', [870000,909999] => 'B+', [910000,949999] => 'A-', [950000,2200000] => 'A'}

third_course_grade_levels = ['Shannon', 'Weaver', 'Vannevar Bush', 'Turing', 'Boole', 'Gardner', 'Shestakov', 'Blackman', 'Bode', 'John Pierce', 'Thorpe', 'Renyi', 'Cohen', 'Berners Lee', 'Nash', 'Cailliau', 'Andreessen', 'Hartill', 'Ada Lovelace', 'Grace Hopper', 'Henrietta Leavitt', 'Anita Borg']

second_course_grade_scheme_hash = { [0,6000] => 'F', [6001,9000] => 'D-', [9001,12000] => 'D', [12001,16000] => 'D+', [16001,19000] => 'C-', [19001,22000] => 'C', [22001,26000] => 'C+', [26001,29000] => 'B-', [29001,32000] => 'B', [32001,36000] => 'B+', [36001,39000] => 'A-', [39001,48000] => 'A' }

second_course_grade_levels = ['Hammurabi', 'Confucius', 'Socrates', 'Cicero', 'William of Ockham', 'Mozi', 'Xenophon', 'Saint Augustine', 'Plato', 'Diogenes', 'Machiavelli', 'Aeschines', 'Ghazali', 'Martin Luther', 'Aristotle', 'Calvin', 'Maimonides', 'St. Thomas Aquinas', 'Xun Zi', 'Ibn Khaldun', 'Thiruvalluvar', 'Locke']

majors = ['Engineering','American Culture','Anthropology','Asian Studies','Astronomy','Cognitive Science','Creative Writing and Literature','English','German','Informatics','Linguistics','Physics']

# Generate sample admin
User.create! do |u|
  u.username = 'albus'
  u.first_name = 'Albus'
  u.last_name = 'Dumbledore'
  u.email = 'dumbledore@hogwarts.edu'
  u.password = 'fawkes'
  u.admin = true
  u.save!
end.activate!
puts "Children must be taught how to think, not what to think.― Margaret Mead"

courses = []

# Generate baseline course with team challenges that are separate from student scores
courses << first_course = Course.create! do |c|
  c.name = "Course with Teams & Badges with Points"
  c.courseno = "GC101"
  c.year = Date.today.year
  c.semester = "Winter"
  c.max_group_size = 5
  c.min_group_size = 3
  c.team_setting = true
  c.teams_visible = true
  c.group_setting = true
  c.badge_setting = true
  c.accepts_submissions = true
  c.predictor_setting = true
  c.tagline = "Games good, school bad. Why?"
  c.academic_history_visible = true
  c.media_credit = "Albus Dumbledore"
  c.media_caption = "The Greatest Wizard Ever Known"
  c.office = "Room 4121 SEB"
  c.phone = "734-644-3674"
  c.class_email = "staff-educ222@umich.edu"
  c.twitter_handle = "barryfishman"
  c.twitter_hashtag = "EDUC222"
  c.location = "Whitney Auditorium, Room 1309 School of Education Building"
  c.office_hours = "Tuesdays, 1:30 pm – 3:30 pm"
  c.meeting_times = "Mondays and Wednesdays, 10:30 am – 12:00 noon"
  c.badge_term = "Badge"
  c.user_term = "Learner"
  c.team_challenges = true
  c.grading_philosophy ="I believe a grading system should put the learner in control of their own destiny, promote autonomy, and reward effort and risk-taking. Whereas most grading systems start you off with 100% and then chips away at that “perfect grade” by averaging in each successive assignment, the grading system in this course starts everyone off at zero, and then gives you multiple ways to progress towards your goals. Different types of assignments are worth differing amounts of points. Some assignments are required of everyone, others are optional. Some assignments can only be done once, others can be repeated for more points. In most cases, the points you earn for an assignment are based on the quality of your work on that assignment. Do poor work, earn fewer points. Do high-quality work, earn more points. You decide what you want your grade to be. Learning in this class should be an active and engaged endeavor."
  c.media = "http://upload.wikimedia.org/wikipedia/commons/3/36/Michigan_Wolverines_Block_M.png"
end
puts "Education is the most powerful weapon which you can use to change the world. - Nelson Mandela"

# Generate course with power ups (badges), unlocks and weighting
courses << second_course = Course.create! do |c|
  c.name = "Course with Power Ups, Unlocks, and Assignment Weighting"
  c.courseno = "GC102"
  c.year = Date.today.year
  c.semester = "Fall"
  c.max_group_size = 5
  c.min_group_size = 3
  c.team_setting = true
  c.team_term = "Section"
  c.teams_visible = false
  c.group_setting = true
  c.badge_setting = true
  c.accepts_submissions = true
  c.predictor_setting = true
  c.academic_history_visible = true
  c.office = "7640 Haven"
  c.phone = "734-644-3674"
  c.class_email = "staff-educ222@umich.edu"
  c.twitter_handle = "polsci101"
  c.twitter_hashtag = "polsci101"
  c.location = "1324 East Hall"
  c.office_hours = "1:30-2:30 Tuesdays, 2:00-3:00 Wednesdays"
  c.meeting_times = "MW 11:30-1"
  c.badge_term = "Power Up"
  c.team_challenges = false
  c.team_score_average = true
  c.total_assignment_weight = 6
  c.default_assignment_weight = 0.5
  c.max_assignment_weight = 3
  c.max_assignment_types_weighted = 3
  c.grading_philosophy = "Think of how video games work. This course works along the same logic. There are some things everyone will have to do to make progress. In this course, the readings, reading-related homework, lectures and discussion sections are those things.
But game play also allows you to choose some activities -- quests, tasks, challenges -- and skip others. You can partly make your own path through a game. So also in this course: the are some assignment types you may choose (because you are good at them, or because you like challenges) and others you can avoid (because your interests are elsewhere). You also have a choice on how you want to weight some of the optional components you choose!
In games, you start with a score of zero and 'level up' as you play. You might have to try some tasks several times before you get the points, but good games don't ever take your points away. Same here: everything you successfully do earns you more points.
In games, you sometimes earn 'trophies' or 'badges' or 'power-ups' as you play. They might not have been your primary goal, but you get them because you do something particularly well. In this course, you also can earn power-ups.
And at the end of the term, your score is your grade."
end
puts "Live as if you were to die tomorrow. Learn as if you were to live forever. ― Mahatma Gandhi"

# Generate course with leaderboards, and team challenges to get added to student scores
courses << third_course = Course.create! do |c|
  c.name = "Course with Leaderboards and Team Challenges"
  c.courseno = "GC103"
  c.year = Date.today.year
  c.semester = "Fall"
  c.team_setting = true
  c.teams_visible = true
  c.group_setting = false
  c.badge_setting = false
  c.accepts_submissions = true
  c.predictor_setting = true
  c.academic_history_visible = true
  c.phone = "777-777-7777"
  c.class_email = "staff-si110@umich.edu"
  c.twitter_handle = "si110"
  c.twitter_hashtag = "si101"
  c.assignment_term = "Quest"
  c.location = "2245 North Quad"
  c.office_hours = "email me"
  c.meeting_times = "TTh 12:00-1:30"
  c.team_challenges = true
  c.team_score_average = true
  c.add_team_score_to_student = true
  c.grading_philosophy = "In this course, we accrue 'XP' which are points that you gain to get to different grade levels. If you can gather 950,000 XP, you will receive an A, not to mention the admiration of those around you. Because you’re in charge of figuring out how many XP you need to get the grade you want, there’s not really such a thing as a required assignment in this course. There are opportunities to gain XP, some of which are scheduled. Of course, you’ll need to do several Quests in order to get higher grade levels, and some Quests count for a ton of XP. Each of these quests is managed in GradeCraft, where you can see your progress, as well as check the forecasting tool to see what you need to do on future assignments to get your desired grade level. A quick note on our assessment philosophy. Most Quests will have rubrics attached, which will spell out our expectations. However, just meeting the details of the assignment is by definition average work, which would receive something around the B category. If your goal is to get an A, you will have to go above and beyond on some of these Quests."
end
puts "I have never let my schooling interfere with my education. ― Mark Twain"

# Generate course with assignment type caps and weights
courses << fourth_course = Course.create! do |c|
  c.name = "Course with Assignment Type Caps"
  c.courseno = "GC104"
  c.year = Date.today.year
  c.semester = "Fall"
  c.team_setting = true
  c.teams_visible = true
  c.group_setting = false
  c.badge_setting = false
  c.accepts_submissions = true
  c.predictor_setting = true
  c.academic_history_visible = true
  c.phone = "777-777-7777"
  c.class_email = "staff-si110@umich.edu"
  c.twitter_handle = "si110"
  c.twitter_hashtag = "si101"
  c.location = "2245 North Quad"
  c.office_hours = "email me"
  c.meeting_times = "TTh 12:00-1:30"
  c.team_challenges = true
  c.team_score_average = true
  c.add_team_score_to_student = true
  c.grading_philosophy = "In this course, we accrue 'XP' which are points that you gain to get to different grade levels. If you can gather 950,000 XP, you will receive an A, not to mention the admiration of those around you. Because you’re in charge of figuring out how many XP you need to get the grade you want, there’s not really such a thing as a required assignment in this course. There are opportunities to gain XP, some of which are scheduled. Of course, you’ll need to do several Quests in order to get higher grade levels, and some Quests count for a ton of XP. Each of these quests is managed in GradeCraft, where you can see your progress, as well as check the forecasting tool to see what you need to do on future assignments to get your desired grade level. A quick note on our assessment philosophy. Most Quests will have rubrics attached, which will spell out our expectations. However, just meeting the details of the assignment is by definition average work, which would receive something around the B category. If your goal is to get an A, you will have to go above and beyond on some of these Quests."
end
puts "You can never be overdressed or overeducated. ― Oscar Wilde"

first_course_grade_scheme_hash.each do |range,letter|
  first_course.grade_scheme_elements.create do |e|
    e.letter = letter
    e.level = first_course_grade_levels.sample
    e.low_range = range.first
    e.high_range = range.last
  end
end
puts "Real learning comes about when the competitive spirit has ceased.― Jiddu Krishnamurti"

third_course_grade_scheme_hash.each do |range,letter|
  third_course.grade_scheme_elements.create do |e|
    e.letter = letter
    e.level = third_course_grade_levels.sample
    e.low_range = range.first
    e.high_range = range.last
  end
end
puts "The world is a book and those who do not travel read only one page.― Augustine of Hippo"


second_course_grade_scheme_hash.each do |range,letter|
  second_course.grade_scheme_elements.create do |e|
    e.letter = letter
    e.level = second_course_grade_levels.shuffle.sample
    e.low_range = range.first
    e.high_range = range.last
  end
end
puts "Education is the ability to listen to almost anything without losing your temper or your self-confidence.― Robert Frost"


first_course_teams = first_course_team_names.map do |team_name|
  first_course.teams.create! do |t|
    t.name = team_name
  end
end
puts "The early bird gets the worm, but the second mouse gets the cheese. ― Willie Nelson"

second_course_teams = second_course_team_names.map do |team_name|
  second_course.teams.create! do |t|
    t.name = team_name
  end
end
puts "It does not matter how slowly you go as long as you do not stop.― Confucius"

third_course_teams = third_course_team_names.map do |team_name|
  third_course.teams.create! do |t|
    t.name = team_name
  end
end
puts "Spoon feeding in the long run teaches us nothing but the shape of the spoon.― E.M. Forster"

# Generate sample students
students = user_names.map do |name|
  first_name, last_name = name.split(' ')
  username = name.parameterize.sub('-','.')
  user = User.create! do |u|
    u.username = username
    u.first_name = first_name
    u.last_name = last_name
    u.email = "#{username}@hogwarts.edu"
    u.password = 'uptonogood'
    u.courses << [ first_course, second_course, third_course, fourth_course ]
    u.teams << [ first_course_teams.sample, second_course_teams.sample, third_course_teams.sample ]
  end
  user.activate!
  user
end
puts "Self-education is, I firmly believe, the only kind of education there is.― Isaac Asimov"


# Generate sample professor
User.create! do |u|
  u.username = 'severus'
  u.first_name = 'Severus'
  u.last_name = 'Snape'
  u.email = 'snape@hogwarts.edu'
  u.password = 'lily'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = third_course
    cm.role = "professor"
  end
end.activate!
puts "In learning you will teach, and in teaching you will learn.― Phil Collins"

# Generate sample professor
User.create! do |u|
  u.username = 'mcgonagall'
  u.first_name = 'Minerva'
  u.last_name = 'McGonagall'
  u.email = 'mcgonagall@hogwarts.edu'
  u.password = 'pineanddragonheart'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = first_course
    cm.role = "professor"
  end
end.activate!
puts "I go to school, but I never learn what I want to know.― Calvin & Hobbes"

# Generate sample professor
User.create! do |u|
  u.username = 'headless_nick'
  u.first_name = 'Nicholas'
  u.last_name = 'de Mimsy-Porpington'
  u.email = 'headless_nick@hogwarts.edu'
  u.password = 'october31'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = second_course
    cm.role = "professor"
  end
end.activate!

# Generate sample GSI
User.create! do |u|
  u.username = 'percy.weasley'
  u.first_name = 'Percy'
  u.last_name = 'Weasley'
  u.email = 'percy.weasley@hogwarts.edu'
  u.password = 'bestprefect'
  u.save!
  courses.each do |c|
    u.course_memberships.create! do |cm|
      cm.course = c
      cm.role = "gsi"
    end
  end
end.activate!

#Create demo academic history content
students.each do |s|
  StudentAcademicHistory.create! do |ah|
    ah.student_id = s.id
    ah.major = majors.sample
    ah.gpa = [1.5, 2.0, 2.25, 2.5, 2.75, 3.0, 3.33, 3.5, 3.75, 4.0, 4.1].sample
    ah.current_term_credits = rand(12)
    ah.accumulated_credits = rand(40)
    ah.year_in_school = [1, 2, 3, 4, 5, 6, 7].sample
    ah.state_of_residence = "Michigan"
    ah.high_school = "Farwell Timberland Alternative High School"
    ah.athlete = [false, true].sample
    ah.act_score = (1..32).to_a.sample
    ah.sat_score = 100 * rand(10)
  end
end

first_course_badges = first_course_badge_names.map do |badge_name|
  first_course.badges.create! do |b|
    b.name = badge_name
    b.point_total = 100 * rand(10)
    b.visible = true
    b.can_earn_multiple_times = [true,false].sample
  end
end

first_course_badges.each do |badge|
  times_earned = 1
  if badge.can_earn_multiple_times
    times_earned = [1,1,2,3].sample
  end
  students.each do |student|
    n = [1, 2, 3, 4, 5].sample
    if n.even?
      times_earned.times do
        student.earned_badges.create! do |eb|
          eb.badge = badge
          eb.course = first_course
        end
      end
    end
  end
end

second_course_badges = second_course_badge_names.map do |badge_name|
  second_course.badges.create! do |b|
    b.name = badge_name
    b.visible = true
    #need to add unlocks here
  end
end

second_course_badges.each do |badge|
  students.each do |student|
    n = [1, 2, 3, 4, 5].sample
    if n.even?
      student.earned_badges.create! do |eb|
        eb.badge = badge
        eb.course = second_course
      end
    end
  end
end


assignment_types = {}

assignment_types[:first_course_grading] = AssignmentType.create! do |at|
  at.course = first_course
  at.name = "Grading Settings"
  at.description = "This category should include all of the different ways assignments can be graded."
  at.position = 1
end
puts "Education consists mainly of what we have unlearned.― Mark Twain, Notebook"

standard_edit_quick_grade_text_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_grading]
  a.name = "Standard Edit + Quick Grade with Text Box"
  a.point_total = 5000
  a.accepts_submissions = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.open_at = 1.weeks.from_now
  a.due_at = 1.weeks.from_now + 0.05
end

standard_edit_quick_grade_checkbox_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_grading]
  a.name = "Standard Edit + Quick Grade with Checkbox"
  a.point_total = 5000
  a.accepts_submissions = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.mass_grade_type = "Checkbox"
  a.open_at = 2.weeks.ago
  a.due_at = 2.weeks.ago + 0.05
end

standard_edit_quick_grade_select_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_grading]
  a.name = "Standard Edit with Select/Quick Grade with Select"
  a.point_total = 5000
  a.accepts_submissions = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.mass_grade_type = "Select List"
  a.open_at = 2.weeks.ago
  a.due_at = 2.weeks.ago + 0.05
end

1.upto(5).each do |n|
  standard_edit_quick_grade_select_assignment.assignment_score_levels.create! do |asl|
    asl.name = "Assignment Score Level ##{n}"
    asl.value = 200000/(6-n)
  end
end

self_log_boolean_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_grading]
  a.name = "Single-level Self-Logged Assignment"
  a.point_total = 5000
  a.accepts_submissions = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = true
  a.open_at = DateTime.now
  a.due_at = DateTime.now + 0.05
end

self_log_score_level_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_grading]
  a.name = "Multi-level Self-Logged Assignment"
  a.point_total = 200000
  a.accepts_submissions = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = true
  a.open_at = DateTime.now
  a.due_at = DateTime.now + 0.05
end

1.upto(5).each do |n|
  self_log_score_level_assignment.assignment_score_levels.create! do |asl|
    asl.name = "Assignment Score Level ##{n}"
    asl.value = 200000/(6-n)
  end
end

standard_edit_release_required = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_grading]
  a.name = "Standard Edit + Release Required"
  a.point_total = 15000
  a.accepts_submissions = false
  a.release_necessary = true
  a.grade_scope = "Individual"
  a.open_at = 3.weeks.from_now
  a.due_at = 3.weeks.from_now + 0.05
end

rubric_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_grading]
  a.name = "Rubric Graded Assignment"
  a.point_total = 80000
  a.due_at = 3.weeks.ago
  a.accepts_submissions = true
  a.release_necessary = true
  a.open_at = 4.weeks.ago
  a.grade_scope = "Individual"
  a.save
  Rubric.create! do |rubric|
    rubric.assignment = a
    rubric.save
    1.upto(15).each do |n|
      rubric.metrics.create! do |metric|
        metric.name = "Criteria ##{n}"
        metric.max_points = [10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000].sample
        metric.order = n
        metric.save
        1.upto(5).each do |m|
          metric.tiers.create! do |tier|
            tier.name = "Tier ##{m}"
            tier.points = metric.max_points - (m * 1000)
          end
        end
      end
    end
  end
  students.each do |student|
    submission = student.submissions.create! do |s|
      s.assignment = a
      s.text_comment = "Wingardium Leviosa"
      s.link = "http://www.twitter.com"
    end
    a.rubric.metrics.each do |metric|
      metric.rubric_grades.create! do |rg|
        rg.max_points = metric.max_points
        rg.points = metric.tiers.first.points
        rg.tier = metric.tiers.first
        rg.metric_name = metric.name
        rg.tier_name = metric.tiers.first.name
        rg.assignment_id = a.id
        rg.order = 1
        rg.student_id = student.id
      end
    end
  end
end
puts "We spend the first year of a child's life teaching it to walk and talk and the rest of its life to shut up and sit down. There's something wrong there.― Neil deGrasse Tyson"

assignment_types[:first_course_submissions] = AssignmentType.create! do |at|
  at.course = first_course
  at.name = "Submission Settings"
  at.description = "This category includes all of the different ways that assignments can handle submissions."
  at.position = 2
end

no_submissions_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_submissions]
  a.name = "Assignment Does Not Accept Submissions"
  a.point_total = 200000
  a.accepts_submissions = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = DateTime.now + 0.05
end

accepts_submissions_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_submissions]
  a.name = "Assignment Accepts All Types of Submissions"
  a.point_total = 200000
  a.accepts_submissions = true
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = DateTime.now + 0.25
end

accepts_link_submissions_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_submissions]
  a.name = "Assignment Accepts Link Submissions"
  a.point_total = 15000
  a.accepts_submissions = true
  a.accepts_links = true 
  a.accepts_attachments = false
  a.accepts_text = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = DateTime.now + 0.25
end

accepts_attachment_submissions_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_submissions]
  a.name = "Assignment Accepts Attachment Submissions"
  a.point_total = 15000
  a.accepts_submissions = true
  a.accepts_links = false
  a.accepts_attachments = true
  a.accepts_text = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = DateTime.now + 0.25
end

accepts_text_submissions_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_submissions]
  a.name = "Assignment Accepts Text Submissions"
  a.point_total = 15000
  a.accepts_submissions = true
  a.accepts_links = false
  a.accepts_attachments = false
  a.accepts_text = true
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = DateTime.now + 0.25
end

assignment_types[:first_course_predictor] = AssignmentType.create! do |at|
  at.course = first_course
  at.name = "Predictor Settings"
end

predictor_fixed_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_predictor]
  a.name = "Assignment Shows Switch in Predictor"
  a.point_total = 15000
  a.accepts_submissions = false
  a.points_predictor_display = "Fixed"
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = 1.week.from_now
end

predictor_continuous_slider_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_predictor]
  a.name = "Assignment Shows Slider (no levels) in Predictor"
  a.point_total = 15000
  a.accepts_submissions = false
  a.points_predictor_display = "Slider"
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = 1.week.from_now
end

predictor_slider_with_levels_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_predictor]
  a.name = "Assignment Shows Slider with Levels in Predictor"
  a.point_total = 25000
  a.accepts_submissions = false
  a.points_predictor_display = "Slider"
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = 1.week.from_now
end

1.upto(5).each do |n|
  predictor_slider_with_levels_assignment.assignment_score_levels.create! do |asl|
    asl.name = "Assignment Score Level ##{n}"
    asl.value = 25000/(6-n)
  end
end

assignment_types[:first_course_visibility] = AssignmentType.create! do |at|
  at.course = first_course
  at.name = "Visibility Settings"
end

invisible_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_visibility]
  a.name = "I'm an Invisible Assignment"
  a.point_total = 15000
  a.visible = false
  a.accepts_submissions = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = 2.week.from_now
end

visible_assignment = Assignment.create! do |a|
  a.course = first_course
  a.assignment_type = assignment_types[:first_course_visibility]
  a.name = "Hey, I'm a Visible Assignment!"
  a.point_total = 12500
  a.visible = true
  a.accepts_submissions = false
  a.release_necessary = false
  a.grade_scope = "Individual"
  a.student_logged = false
  a.due_at = 2.week.from_now
end
