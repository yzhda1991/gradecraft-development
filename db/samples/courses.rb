#------------------------------------------------------------------------------#

#                        COURSE DEFAULT CONFIGURATION                          #

#------------------------------------------------------------------------------#

# Add all attributes that will be passed on any course creation here, with a
# default value
# All courses will use defaults when individual attributes aren't supplied

@course_default_config = {
  quotes: {
    course_created: "A new course has been created",
    grade_scheme_elements_created:
      "Grade scheme elements have been added for the course",
    teams_created: "Teams have been added for the course",
    badges_created: "Badges have been added for the course",
    weights_created: "Weights have been configured for the course"
  },
  # All courses must have grade scheme elements
  grade_scheme_hash: { [0,599_999] => "F", [600000,649000] => "D+",
    [650_000,699_999] => "C-", [700_000,749_999] => "C", [750_000,799_999] => "C+",
    [800_000,849_999] => "B-", [850_000,899_999] => "B", [900_000,949_999] => "B+",
    [950_000,999_999] => "A-", [1_000_000,1_244_999] => "A",
    [1_245_000,1_600_000] => "A+"
  },
  grade_levels: ["Amoeba", "Sponge", "Roundworm", "Jellyfish", "Leech", "Snail",
    "Sea Slug", "Fruit Fly", "Lobster", "Ant", "Honey Bee", "Cockroach", "Frog",
    "Mouse", "Rat", "Octopus", "Cat", "Chimpanzee", "Elephant", "Human",
    "Orca"].shuffle,
  # Not all courses have teams
  team_names: ["Harm & Hammer","Abusement Park","Silver Woogidy Woogidy Snakes",
    "Carpe Ludus","Eduception","Operation Unthinkable","Team Wang",
    "The Carpal Tunnel Crusaders","Pwn Depot"].shuffle,
  attributes: {
    accepts_submissions: false,
    add_team_score_to_student: false,
    assignment_term: "Assignment",
    has_badges: false,
    badge_term: "Badge",
    challenge_term: "Challenge",
    has_character_names: false,
    has_character_profiles: false,
    has_multipliers: false,
    class_email: nil,
    course_number: "ABC101",
    gameful_philosophy: nil,
    has_in_team_leaderboards: false,
    location: nil,
    meeting_times: nil,
    name: "Generic course with Minimum Requirements",
    office: nil,
    office_hours: nil,
    phone: nil,
    published: true,
    semester: "Winter",
    tagline: nil,
    has_team_challenges: false,
    has_team_roles: false,
    team_score_average: false,
    has_teams: false,
    team_term: "Team",
    teams_visible: false,
    total_weights: 0,
    twitter_handle: nil,
    twitter_hashtag: nil,
    student_term: "Student",
    year: Date.today.year,
    status: true,
    has_learning_objectives: false,
    allows_learning_objectives: false
  }
}

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

# Note: @courses will hold each course as a hash key.
# The custom attributes should be defined below and will be available throughout
# sample creation.
#
# Additionally, The Active record models associated with the course be
# accessible on each course:
# Course: @courses[:course_name][:course] => Course
# Teams:  @courses[:course_name][:teams] => array of Teams
# Assignment Types: @courses[:course_name][:assignment_types] =>
# hash of AssignmentTypes
# Assignments: @courses[:course_name][:assignments] => hash of Assignments
# Challenges: @courses[:course_name][:challenges] => hash of Challenges
# Badges: @courses[:course_name][:challenges] => hash of Badges

# Create Courses!
@courses = {}

# Define courses in @courses, override default attributes

@courses[:teams_badges_points] = {
  quotes: {
    course_created: "Education is the most powerful weapon which you can use \
to change the world. - Nelson Mandela",
    grade_sceme_elements_created: "Real learning comes about when the \
competitive spirit has ceased. ― Jiddu Krishnamurti",
    teams_created: "The early bird gets the worm, but the second mouse gets \
the cheese. ― Willie Nelson",
  },
  attributes: {
    accepts_submissions: true,
    has_badges: true,
    badge_term: "Badge",
    class_email: "staff-educ222@umich.edu",
    course_number: "GC101",
    gameful_philosophy: "I believe a grading system should put the learner in
      control of their own destiny, promote autonomy, and reward effort and
      risk-taking. Whereas most grading systems start you off with 100% and
      then chips away at that “perfect grade” by averaging in each successive
      assignment, the grading system in this course starts everyone off at zero,
      and then gives you multiple ways to progress towards your goals. Different
      types of assignments are worth differing amounts of points. Some
      assignments are required of everyone, others are optional. Some
      assignments can only be done once, others can be repeated for more points.
      In most cases, the points you earn for an assignment are based on the
      quality of your work on that assignment. Do poor work, earn fewer points.
      Do high-quality work, earn more points. You decide what you want your
      grade to be. Learning in this class should be an active and engaged
      endeavor.",
    location: "Whitney Auditorium, Room 1309 School of Education Building",
    meeting_times: "Mondays and Wednesdays, 10:30 am – 12:00 noon",
    name: "Course with Teams & Badges with Points",
    office: "Room 4121 SEB",
    office_hours: "Tuesdays, 1:30 pm – 3:30 pm",
    phone: "734-644-3674",
    tagline: "Games good, school bad. Why?",
    has_team_challenges: true,
    has_teams: true,
    teams_visible: true,
    twitter_handle: "barryfishman",
    twitter_hashtag: "EDUC222",
    student_term: "Learner",
  }
}

@courses[:power_ups_locks_weighting_config] = {
  quotes: {
    course_created: "Live as if you were to die tomorrow. Learn as if you were \
to live forever. ― Mahatma Gandhi",
    grade_sceme_elements_created: "Education is the ability to listen to \
almost anything without losing your temper or your self-confidence―Robert \
Frost",
    teams_created: "The best thing for being sad, replied Merlin, beginning to \
puff and blow, is to learn something. That's the only thing that never \
fails. - Merlin via T.H. White",
    badges_created: "Self-education is, I firmly believe, the only kind of \
education there is. ― Isaac Asimov",
    weights_created: nil
  },
  grade_levels: ["Hammurabi", "Confucius", "Socrates", "Cicero",
    "William of Ockham", "Mozi", "Xenophon", "Saint Augustine", "Plato",
    "Diogenes", "Machiavelli", "Aeschines", "Ghazali", "Martin Luther",
    "Aristotle", "Calvin", "Maimonides", "St. Thomas Aquinas", "Xun Zi",
    "Ibn Khaldun", "Thiruvalluvar", "Locke"].shuffle,
  team_names: ["Section 1", "Section 2", "Section 3", "Section 4", "Section 5",
    "Section 6", "Section 7", "Section 8", "Section 9", "Section 10",
    "Section 11", "Section 12", "Section 13", "Section 14", "Section 15",
    "Section 16"].shuffle,
  attributes: {
    accepts_submissions: true,
    has_badges: true,
    badge_term: "Power Up",
    class_email: "staff-educ222@umich.edu",
    course_number: "GC102",
    gameful_philosophy: gameful_philosophy = "Think of how video games work.
      This course works along the same logic. There are some things everyone
      will have to do to make progress. In this course, the readings,
      reading-related homework, lectures and discussion sections are those
      things. But game play also allows you to choose some activities -- quests,
      tasks, challenges -- and skip others. You can partly make your own path
      through a game. So also in this course: the are some assignment types you
      may choose(because you are good at them, or because you like challenges)
      and others you can avoid (because your interests are elsewhere). You also
      have a choice on how you want to weight some of the optional components
      you choose! In games, you start with a score of zero and 'level up' as you
      play. You might have to try some tasks several times before you get the
      points, but good games don't ever take your points away. Same here:
      everything you successfully do earns you more points. In games, you
      sometimes earn 'trophies' or 'badges' or 'power-ups' as you play. They
      might not have been your primary goal, but you get them because you do
      something particularly well. In this course, you also can earn power-ups.
      And at the end of the term, your score is your grade.",
    location: "1324 East Hall",
    meeting_times: "MW 11:30-1",
    name: "Course with Power Ups, Unlocks, and Assignment Weighting",
    office: "7640 Haven",
    office_hours: "1:30-2:30 Tuesdays, 2:00-3:00 Wednesdays",
    phone: "734-644-3674",
    semester: "Fall",
    has_team_challenges: false,
    has_multipliers: true,
    team_score_average: true,
    has_teams: true,
    team_term: "Section",
    total_weights: 6,
    twitter_handle: "polsci101",
    twitter_hashtag: "polsci101",
    weight_attributes: {
      max_assignment_types_weighted: 2,
      max_weights_per_assignment_type: 4,
    }
  }
}

@courses[:leaderboards_team_challenges] = {
  quotes: {
    course_created:
      "I have never let my schooling interfere with my education. ― Mark Twain",
    grade_sceme_elements_created: "The world is a book and those who do not \
travel read only one page. ― Augustine of Hippo",
    teams_created: "Spoon feeding in the long run teaches us nothing but the \
shape of the spoon. ― E.M. Forster",
  },
  grade_levels: ["Shannon", "Weaver", "Vannevar Bush", "Turing", "Boole",
    "Gardner", "Shestakov", "Blackman", "Bode", "John Pierce", "Thorpe",
    "Renyi", "Cohen", "Berners Lee", "Nash", "Cailliau", "Andreessen",
    "Hartill", "Ada Lovelace", "Grace Hopper", "Henrietta Leavitt",
    "Anita Borg"].shuffle,
  team_names: ["Late Night Information Nation", "Heisenberg", "Big Red Dogs",
    "Liu Man Group", "The House that Cliff Built", "TMI"].shuffle,
  attributes: {
    accepts_submissions: true,
    add_team_score_to_student: true,
    assignment_term: "Quest",
    challenge_term: "Ambush",
    has_character_names: true,
    has_character_profiles: true,
    class_email: "staff-si110@umich.edu",
    course_number: "GC103",
    gameful_philosophy: "In this course, we accrue 'XP' which are points that
      you gain to get to different grade levels. If you can gather 950,000 XP,
      you will receive an A, not to mention the admiration of those around you.
      Because you’re in charge of figuring out how many XP you need to get the
      grade you want, there’s not really such a thing as a required assignment
      in this course. There are opportunities to gain XP, some of which are
      scheduled. Of course, you’ll need to do several Quests in order to get
      higher grade levels, and some Quests count for a ton of XP. Each of these
      quests is managed in GradeCraft, where you can see your progress, as well
      as check the forecasting tool to see what you need to do on future
      assignments to get your desired grade level. A quick note on our
      assessment philosophy. Most Quests will have rubrics attached, which will
      spell out our expectations. However, just meeting the details of the
      assignment is by definition average work, which would receive something
      around the B category. If your goal is to get an A, you will have to go
      above and beyond on some of these Quests.",
    has_in_team_leaderboards: true,
    location: "2245 North Quad",
    meeting_times: "TTh 12:00-1:30",
    name: "Course with Leaderboards and Team Challenges",
    office_hours: "email me",
    phone: "777-777-7777",
    semester: "Fall",
    has_team_challenges: true,
    has_team_roles: true,
    team_score_average: true,
    has_teams: true,
    teams_visible: true,
    twitter_handle: "si110",
    twitter_hashtag: "si101",
  }
}

@courses[:assignment_type_caps_config] = {
  quotes: {
    course_created: "You can never be overdressed or overeducated― Oscar Wilde",
    grade_sceme_elements_created: "To emphasize only the beautiful seems to \
me to be like a mathematical system that only concerns itself with positive \
numbers. ― Paul Klee",
    teams_created: "We learn from failure, not from success! ― Bram Stoker, \
Dracula",
  },
  grade_levels: ["Arp", "Breton", "Dali", "Duchamp", "Earnst", "Giacometti",
    "Magritte", "Masson", "Miro", "Oppenheim", "Ray", "Tanguy"].shuffle,
  attributes: {
    accepts_submissions: true,
    class_email: "staff-si110@umich.edu",
    course_number: "GC104",
    gameful_philosophy: "In this course, we accrue 'XP' which are points that
      you gain to get to different grade levels. If you can gather 950,000 XP,
      you will receive an A, not to mention the admiration of those around you.
      Because you’re in charge of figuring out how many XP you need to get the
      grade you want, there’s not really such a thing as a required assignment
      in this course. There are opportunities to gain XP, some of which are
      scheduled. Of course, you’ll need to do several Quests in order to get
      higher grade levels, and some Quests count for a ton of XP. Each of these
      quests is managed in GradeCraft, where you can see your progress, as well
      as check the forecasting tool to see what you need to do on future
      assignments to get your desired grade level. A quick note on our
      assessment philosophy. Most Quests will have rubrics attached, which will
      spell out our expectations. However, just meeting the details of the
      assignment is by definition average work, which would receive something
      around the B category. If your goal is to get an A, you will have to go
      above and beyond on some of these Quests.",
    location: "2245 North Quad",
    meeting_times: "TTh 12:00-1:30",
    name: "Course with Assignment Type Caps",
    office_hours: "email me",
    phone: "777-777-7777",
    semester: "Fall",
    has_teams: true,
    twitter_handle: "si110",
    twitter_hashtag: "si101",
  }
}

@courses[:no_dates_no_info] = {
  quotes: {
    course_created: "“To live is the rarest thing in the world. Most people \
    exist, that is all.” ― Oscar Wilde",
    grade_sceme_elements_created: " ",
    teams_created: " ",
  },
  grade_levels: ["Arp", "Breton", "Dali", "Duchamp", "Earnst", "Giacometti",
    "Magritte", "Masson", "Miro", "Oppenheim", "Ray", "Tanguy"].shuffle,
  no_due_dates: true,
  attributes: {
    accepts_submissions: true,
    course_number: "GC105",
    gameful_philosophy: "In this course, there are no due dates, and no sequencing \
    to the assignments. Show us you've completed the necessary competencies in any \
    way you like.",
    name: "Course with No Dates",
    semester: "Fall",
    has_teams: true,
  }
}

@courses[:inactive_course] = {
  quotes: {
    course_created: "“Stay hungry, stay foolish” ― Steve Jobs",
    grade_sceme_elements_created: "“Stay thirsty my friends” - The most interesting man in the world",
    teams_created: "“Don't cry because it's over, smile because it happened.” - Dr. Seuss",
  },
  attributes: {
    status: false,
    accepts_submissions: true,
    course_number: "GC106",
    gameful_philosophy: "This course is inactive. None shall pass.",
    name: "Inactive course",
    semester: "Fall",
    has_teams: true,
  }
}

@courses[:with_learning_objectives] = {
  quotes: {
    course_created: "“Reach for the sky” ― Woody",
    grade_sceme_elements_created: "“To infinity and beyond” - Buzz",
  },
  grade_levels: ["Rex", "Slinky", "Woody", "Buzz", "Mr. Potato Head", "Mrs. Potato Head",
    "Barbie", "Sarge", "RC", "Bo Peep", "Etch", "Hamm"].shuffle,
  attributes: {
    course_number: "GC107",
    accepts_submissions: true,
    name: "Course with Learning Objectives",
    semester: "Fall",
    has_teams: true,
    has_team_challenges: true,
    teams_visible: true,
    has_learning_objectives: true,
    allows_learning_objectives: true
  }
}
