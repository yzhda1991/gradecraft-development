# Output quotes for each successful step passed
def puts_success(type, name, event)
  puts eval("@#{type}s")[name][:quotes][event] || eval("@#{type}_default_config")[:quotes][event] + ": #{name}"
end

user_names = ['Ron Weasley','Fred Weasley','Harry Potter','Hermione Granger','Colin Creevey','Seamus Finnigan','Hannah Abbott',
  'Pansy Parkinson','Zacharias Smith','Blaise Zabini', 'Draco Malfoy', 'Dean Thomas', 'Millicent Bulstrode', 'Terry Boot', 'Ernie Macmillan',
  'Roland Abberlay', 'Katie Bell', 'Regulus Black', 'Euan Abercrombie', 'Brandon Angel']

majors = ['Engineering','American Culture','Anthropology','Asian Studies','Astronomy','Cognitive Science','Creative Writing and Literature','English','German','Informatics','Linguistics','Physics']
pseuydonyms = ['Bigby Wolf', 'Snow White', 'Beauty', 'the Beast', 'Trusty John', 'Grimble', 'Bufkin', 'Prince Charming', 'Cinderella', 'Old King Cole','Hobbes', 'Pinocchio', 'Briar Rose', 'Doctor Swineheart', 'Rapunzel', 'Kay', 'Mrs. Sprat', 'Frau Totenkinder', 'Ozma', 'Great Fairy Witch','Maddy', 'Mr. Grandours', 'Mrs. Someone', 'Prospero', 'Mr. Kadabra','Geppetto', 'Morgan le Fay','Rose Red','Boy Blue','Weyland Smith','Reynard the Fox','Brock Blueheart','Peter Piper','Bo Peep','The Adversary','Goldilocks','Bluebeard','Ichabod Crane','Baba Yaga','The Snow Queen','Rodney', 'June', 'Hansel', 'The Nome King', 'Max Piper', 'Mister Dark', 'Fairy Godmother', 'Dorothy Gale', 'Hadeon the Destroyer', 'Prince Brandish']

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

#----------------------------------------------------------------------------------------------------------------------#

#                                          COURSE DEFAULT CONFIGURATION                                                #

#----------------------------------------------------------------------------------------------------------------------#

# Add all attributes that will be passed on any course creation here, with a default value
# All courses will use defaults when individual attributes aren't supplied

@course_default_config = {
  :quotes => {
    :course_created => "A new course has been created",
    :grade_sceme_elements_created => "Grade scheme elements have been added for the course",
    :teams_created => "Teams have been added for the course",
    :badges_created => "Badges have been added for the course",
    :weights_created => "Weights have been configured for the course"
  },
  # All courses must have grade scheme elements
  :grade_scheme_hash => { [0,600000] => 'F', [600000,649000] => 'D+', [650000,699999] => 'C-', [700000,749999] => 'C', [750000,799999] => 'C+', [800000,849999] => 'B-', [850000,899999] => 'B', [900000,949999] => 'B+', [950000,999999] => 'A-', [1000000,1244999] => 'A', [1245000,1600000] => 'A+'},
  :grade_levels => ['Amoeba', 'Sponge', 'Roundworm', 'Jellyfish', 'Leech', 'Snail', 'Sea Slug', 'Fruit Fly', 'Lobster', 'Ant', 'Honey Bee', 'Cockroach', 'Frog', 'Mouse', 'Rat', 'Octopus', 'Cat', 'Chimpanzee', 'Elephant', 'Human', 'Orca'].shuffle,
    # Not all courses have teams
  :team_names => ['Harm & Hammer','Abusement Park','Silver Woogidy Woogidy Woogidy Snakes','Carpe Ludus','Eduception','Operation Unthinkable','Team Wang','The Carpal Tunnel Crusaders','Pwn Depot'].shuffle,
    # Not all courses have badges
  :badge_names => ['Creative', 'Inner Eye', 'Patronus Producer','Cheerful Charmer','Invisiblity Cloak','Marauders Map','Lumos','Rune Reader','Tea Leaf Guru','Wizard Chess Grand Master','Green Thumb','Gamekeeper','Seeker','Alchemist','Healer','Parseltongue','House Cup'].shuffle,
  :attributes => {
    :academic_history_visible => false,
    :accepts_submissions => false,
    :add_team_score_to_student => false,
    :assignment_term => nil,
    :badge_setting => false,
    :badge_term => nil,
    :challenge_term => nil,
    :character_names => false,
    :character_profiles => false,
    :class_email => nil,
    :courseno => "ABC101",
    :grading_philosophy => nil,
    :group_setting => false,
    :in_team_leaderboard => false,
    :location => nil,
    :max_group_size => nil,
    :media => nil,
    :media_caption => nil,
    :media_credit => nil,
    :meeting_times => nil,
    :min_group_size => nil,
    :name => "Generic course with Minimum Requirements",
    :office => nil,
    :office_hours => nil,
    :phone => nil,
    :semester => "Winter",
    :tagline => nil,
    :team_challenges => false,
    :team_roles => false,
    :team_score_average => false,
    :team_setting => false,
    :team_term => false,
    :teams_visible => false,
    :total_assignment_weight => 0,
    :twitter_handle => nil,
    :twitter_hashtag => nil,
    :user_term => nil,
    :year => Date.today.year,
  }
}

#----------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------#

# Note: @courses will hold each course as a hash key.
# The custom attributes should be defined below and will be available throughout sample creation.
#
# Additionally, The Active record models associated with the course be accessible on each course:
# Course: @courses[:course_name][:course] => Course
# Teams:  @courses[:course_name][:teams] => array of Teams
# Assignment Types: @courses[:course_name][:assignment_types] => hash of AssignmentTypes
# Assignments: @courses[:course_name][:assignments] => hash of Assignments
# Challenges: @courses[:course_name][:challenges] => hash of Challenges
# Badges: @courses[:course_name][:challenges] => hash of Badges

# Create Courses!
@courses = {}

# Define courses in @courses, override default attributes

@courses[:teams_badges_points] = {
  :quotes => {
    :course_created => "Education is the most powerful weapon which you can use to change the world. - Nelson Mandela",
    :grade_sceme_elements_created => "Real learning comes about when the competitive spirit has ceased. ― Jiddu Krishnamurti",
    :teams_created => "The early bird gets the worm, but the second mouse gets the cheese. ― Willie Nelson",
  },
  :attributes => {
    :academic_history_visible => true,
    :accepts_submissions => true,
    :badge_setting => true,
    :badge_term => "Badge",
    :class_email => "staff-educ222@umich.edu",
    :courseno => "GC101",
    :grading_philosophy => "I believe a grading system should put the learner in control of their own destiny, promote autonomy, and reward effort and risk-taking. Whereas most grading systems start you off with 100% and then chips away at that “perfect grade” by averaging in each successive assignment, the grading system in this course starts everyone off at zero, and then gives you multiple ways to progress towards your goals. Different types of assignments are worth differing amounts of points. Some assignments are required of everyone, others are optional. Some assignments can only be done once, others can be repeated for more points. In most cases, the points you earn for an assignment are based on the quality of your work on that assignment. Do poor work, earn fewer points. Do high-quality work, earn more points. You decide what you want your grade to be. Learning in this class should be an active and engaged endeavor.",
    :group_setting => true,
    :location => "Whitney Auditorium, Room 1309 School of Education Building",
    :max_group_size => 5,
    :media => "http://upload.wikimedia.org/wikipedia/commons/3/36/Michigan_Wolverines_Block_M.png",
    :media_caption => "The Greatest Wizard Ever Known",
    :media_credit => "Albus Dumbledore",
    :meeting_times => "Mondays and Wednesdays, 10:30 am – 12:00 noon",
    :min_group_size => 3,
    :name => "Course with Teams & Badges with Points",
    :office => "Room 4121 SEB",
    :office_hours => "Tuesdays, 1:30 pm – 3:30 pm",
    :phone => "734-644-3674",
    :tagline => "Games good, school bad. Why?",
    :team_challenges => true,
    :team_setting => true,
    :teams_visible => true,
    :twitter_handle => "barryfishman",
    :twitter_hashtag => "EDUC222",
    :user_term => "Learner",
  }
}

@courses[:power_ups_locks_weighting_config] = {
  :quotes => {
    :course_created => "Live as if you were to die tomorrow. Learn as if you were to live forever. ― Mahatma Gandhi",
    :grade_sceme_elements_created => "Education is the ability to listen to almost anything without losing your temper or your self-confidence.― Robert Frost",
    :teams_created => "The best thing for being sad, replied Merlin, beginning to puff and blow, is to learn something. That's the only thing that never fails. - Merlin via T.H. White",
    :badges_created => "Self-education is, I firmly believe, the only kind of education there is. ― Isaac Asimov",
    :weights_created => nil
  },
  :grade_levels => ['Hammurabi', 'Confucius', 'Socrates', 'Cicero', 'William of Ockham', 'Mozi', 'Xenophon', 'Saint Augustine', 'Plato', 'Diogenes', 'Machiavelli', 'Aeschines', 'Ghazali', 'Martin Luther', 'Aristotle', 'Calvin', 'Maimonides', 'St. Thomas Aquinas', 'Xun Zi', 'Ibn Khaldun', 'Thiruvalluvar', 'Locke'].shuffle,
  :team_names => ['Section 1', 'Section 2', 'Section 3', 'Section 4', 'Section 5', 'Section 6', 'Section 7', 'Section 8', 'Section 9', 'Section 10', 'Section 11', 'Section 12', 'Section 13', 'Section 14', 'Section 15', 'Section 16'].shuffle,
  :badge_names => ['MINOR: Learning from Mistakes', 'MINOR: Learning from Mistakes', 'MINOR: Halloween Special', 'MINOR: Thanksgiving Special', 'MINOR: Now It is Personal', 'MAJOR: Makeup Much', 'MAJOR: Practice Makes Perfect', 'MAJOR: Combo Platter', 'MINOR: Makeup Some', 'MINOR: Participatory Democrat', 'MINOR: Number One', 'MINOR: Rockstar', 'MINOR: Over-achiever', 'MINOR: Avid Reader', 'MINOR: Nice Save!', 'MINOR: The Nightstalker', 'MINOR: Paragon of Virtue', 'MAJOR: Bad Investment', 'MINOR: Leader of the pack', 'MINOR: Thoughtful Contribution'].shuffle,
  :attributes => {
    :academic_history_visible => true,
    :accepts_submissions => true,
    :badge_setting => true,
    :badge_term => "Power Up",
    :class_email => "staff-educ222@umich.edu",
    :courseno => "GC102",
    :grading_philosophy => grading_philosophy = "Think of how video games work. This course works along the same logic. There are some things everyone will have to do to make progress. In this course, the readings, reading-related homework, lectures and discussion sections are those things.
  But game play also allows you to choose some activities -- quests, tasks, challenges -- and skip others. You can partly make your own path through a game. So also in this course: the are some assignment types you may choose (because you are good at them, or because you like challenges) and others you can avoid (because your interests are elsewhere). You also have a choice on how you want to weight some of the optional components you choose!
  In games, you start with a score of zero and 'level up' as you play. You might have to try some tasks several times before you get the points, but good games don't ever take your points away. Same here: everything you successfully do earns you more points.
  In games, you sometimes earn 'trophies' or 'badges' or 'power-ups' as you play. They might not have been your primary goal, but you get them because you do something particularly well. In this course, you also can earn power-ups.
  And at the end of the term, your score is your grade.",
    :group_setting => true,
    :location => "1324 East Hall",
    :max_group_size => 5,
    :meeting_times => "MW 11:30-1",
    :min_group_size => 3,
    :name => "Course with Power Ups, Unlocks, and Assignment Weighting",
    :office => "7640 Haven",
    :office_hours => "1:30-2:30 Tuesdays, 2:00-3:00 Wednesdays",
    :phone => "734-644-3674",
    :semester => "Fall",
    :team_challenges => false,
    :team_score_average => true,
    :team_setting => true,
    :team_term => "Section",
    :total_assignment_weight => 6,
    :twitter_handle => "polsci101",
    :twitter_hashtag => "polsci101",
    :weight_attributes => {
      :max_assignment_types_weighted => 2,
      :max_assignment_weight => 4,
      :default_assignment_weight => 0.5,
    }
  }
}

@courses[:leaderboards_team_challenges] = {
  :quotes => {
    :course_created => "I have never let my schooling interfere with my education. ― Mark Twain",
    :grade_sceme_elements_created => "The world is a book and those who do not travel read only one page. ― Augustine of Hippo",
    :teams_created => "Spoon feeding in the long run teaches us nothing but the shape of the spoon. ― E.M. Forster",
  },
  :grade_levels => ['Shannon', 'Weaver', 'Vannevar Bush', 'Turing', 'Boole', 'Gardner', 'Shestakov', 'Blackman', 'Bode', 'John Pierce', 'Thorpe', 'Renyi', 'Cohen', 'Berners Lee', 'Nash', 'Cailliau', 'Andreessen', 'Hartill', 'Ada Lovelace', 'Grace Hopper', 'Henrietta Leavitt', 'Anita Borg'].shuffle,
  :team_names => ['Late Night Information Nation', 'Heisenberg', 'Big Red Dogs', 'Liu Man Group', 'The House that Cliff Built', 'TMI'].shuffle,
  :badge_names => ['MINOR: Learning from Mistakes', 'MINOR: Learning from Mistakes', 'MINOR: Halloween Special', 'MINOR: Thanksgiving Special', 'MINOR: Now It is Personal', 'MAJOR: Makeup Much', 'MAJOR: Practice Makes Perfect', 'MAJOR: Combo Platter', 'MINOR: Makeup Some', 'MINOR: Participatory Democrat', 'MINOR: Number One', 'MINOR: Rockstar', 'MINOR: Over-achiever', 'MINOR: Avid Reader', 'MINOR: Nice Save!', 'MINOR: The Nightstalker', 'MINOR: Paragon of Virtue', 'MAJOR: Bad Investment', 'MINOR: Leader of the pack', 'MINOR: Thoughtful Contribution'].shuffle,
  :attributes => {
    :academic_history_visible => true,
    :accepts_submissions => true,
    :add_team_score_to_student => true,
    :assignment_term => "Quest",
    :challenge_term => "Ambush",
    :character_names => true,
    :character_profiles => true,
    :class_email => "staff-si110@umich.edu",
    :courseno => "GC103",
    :grading_philosophy => "In this course, we accrue 'XP' which are points that you gain to get to different grade levels. If you can gather 950,000 XP, you will receive an A, not to mention the admiration of those around you. Because you’re in charge of figuring out how many XP you need to get the grade you want, there’s not really such a thing as a required assignment in this course. There are opportunities to gain XP, some of which are scheduled. Of course, you’ll need to do several Quests in order to get higher grade levels, and some Quests count for a ton of XP. Each of these quests is managed in GradeCraft, where you can see your progress, as well as check the forecasting tool to see what you need to do on future assignments to get your desired grade level. A quick note on our assessment philosophy. Most Quests will have rubrics attached, which will spell out our expectations. However, just meeting the details of the assignment is by definition average work, which would receive something around the B category. If your goal is to get an A, you will have to go above and beyond on some of these Quests.",
    :in_team_leaderboard => true,
    :location => "2245 North Quad",
    :meeting_times => "TTh 12:00-1:30",
    :name => "Course with Leaderboards and Team Challenges",
    :office_hours => "email me",
    :phone => "777-777-7777",
    :semester => "Fall",
    :team_challenges => true,
    :team_roles => true,
    :team_score_average => true,
    :team_setting => true,
    :teams_visible => true,
    :twitter_handle => "si110",
    :twitter_hashtag => "si101",
  }
}

@courses[:assignment_type_caps_config] = {
  :quotes => {
    :course_created => "You can never be overdressed or overeducated. ― Oscar Wilde",
    :grade_sceme_elements_created => "To emphasize only the beautiful seems to me to be like a mathematical system that only concerns itself with positive numbers. ― Paul Klee",
    :teams_created => "We learn from failure, not from success! ― Bram Stoker, Dracula",
  },
  :grade_levels => ['Arp', 'Breton', 'Dali', 'Duchamp', 'Earnst', 'Giacometti', 'Magritte', 'Masson', 'Miro', 'Oppenheim', 'Ray', 'Tanguy'].shuffle,
  :attributes => {
    :academic_history_visible => true,
    :accepts_submissions => true,
    :class_email => "staff-si110@umich.edu",
    :courseno => "GC104",
    :grading_philosophy => "In this course, we accrue 'XP' which are points that you gain to get to different grade levels. If you can gather 950,000 XP, you will receive an A, not to mention the admiration of those around you. Because you’re in charge of figuring out how many XP you need to get the grade you want, there’s not really such a thing as a required assignment in this course. There are opportunities to gain XP, some of which are scheduled. Of course, you’ll need to do several Quests in order to get higher grade levels, and some Quests count for a ton of XP. Each of these quests is managed in GradeCraft, where you can see your progress, as well as check the forecasting tool to see what you need to do on future assignments to get your desired grade level. A quick note on our assessment philosophy. Most Quests will have rubrics attached, which will spell out our expectations. However, just meeting the details of the assignment is by definition average work, which would receive something around the B category. If your goal is to get an A, you will have to go above and beyond on some of these Quests.",
    :location => "2245 North Quad",
    :meeting_times => "TTh 12:00-1:30",
    :name => "Course with Assignment Type Caps",
    :office_hours => "email me",
    :phone => "777-777-7777",
    :semester => "Fall",
    :team_setting => true,
    :twitter_handle => "si110",
    :twitter_hashtag => "si101",
  }
}


# Itereate through course names and create courses
@courses.each do |course_name, config|
  course = Course.create! do |c|
    @course_default_config[:attributes].keys.each do |attr|
      c[attr] = config[:attributes][attr] || @course_default_config[:attributes][attr]
    end

    # Add weight attributes if course has weights
    if config[:attributes][:total_assignment_weight] && (config[:attributes][:total_assignment_weight] > 1)
      config[:attributes][:weight_attributes].keys.each do |weight_attr|
        c[weight_attr] = config[:attributes][:weight_attributes][weight_attr]
      end
      puts_success :course, course_name, :weights_created
    end
  end

  config[:course] = course
  puts_success :course, course_name, :course_created

  # Add the grade scheme elements and level names
  grade_scheme_hash = config[:grade_scheme_hash] || @course_default_config[:grade_scheme_hash]
  levels = config[:grade_levels] || @course_default_config[:grade_levels]
  grade_scheme_hash.each_with_index do |(range,letter),i|
    course.grade_scheme_elements.create do |e|
      e.letter = letter
      e.level = levels[i]
      e.low_range = range.first
      e.high_range = range.last
    end
  end
  puts_success :course, course_name, :grade_sceme_elements_created

  # Add the course teams if the course has teams
  if config[:attributes][:team_setting]
    team_names = config[:team_names] || @course_default_config[:team_names]
    teams = team_names.map do |team_name|
      course.teams.create! do |t|
        t.name = team_name
      end
    end
    @courses[course_name][:teams] = teams
    puts_success :course, course_name, :teams_created
  end
end

# create a hash on each course config to store assignment types and assignments
@courses.each do |name,config|
  config[:badges] = {}
  config[:assignment_types] = {}
  config[:assignments] = {}
  config[:challenges] = {}
end

# Generate sample students
@students = user_names.map do |name|
  courses = @courses.map {|name,config| config[:course]}
  teams = @courses.map {|name,config| config[:teams].sample}

  first_name, last_name = name.split(' ')
  username = name.parameterize.sub('-','.')
  user = User.create! do |u|
    u.username = username
    u.first_name = first_name
    u.last_name = last_name
    u.email = "#{username}@hogwarts.edu"
    u.password = 'uptonogood'
    u.courses << courses
    u.teams << teams
    u.display_name = pseuydonyms.sample
  end
  user.activate!
  print "."
  user
end
puts "Everything starts from a dot. - Kandinsky"

# Generate sample professor
User.create! do |u|
  u.username = 'mcgonagall'
  u.first_name = 'Minerva'
  u.last_name = 'McGonagall'
  u.email = 'mcgonagall@hogwarts.edu'
  u.password = 'pineanddragonheart'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = @courses[:teams_badges_points][:course]
    cm.role = "professor"
  end
end.activate!

# Generate sample professor
User.create! do |u|
  u.username = 'headless_nick'
  u.first_name = 'Nicholas'
  u.last_name = 'de Mimsy-Porpington'
  u.email = 'headless_nick@hogwarts.edu'
  u.password = 'october31'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = @courses[:power_ups_locks_weighting_config][:course]
    cm.role = "professor"
  end
end.activate!

# Generate sample professor
User.create! do |u|
  u.username = 'severus'
  u.first_name = 'Severus'
  u.last_name = 'Snape'
  u.email = 'snape@hogwarts.edu'
  u.password = 'lily'
  u.save!
  u.course_memberships.create! do |cm|
    cm.course = @courses[:leaderboards_team_challenges][:course]
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
  @courses.each do |name,config|
    u.course_memberships.create! do |cm|
      cm.course = config[:course]
      cm.role = "gsi"
    end
  end
end.activate!
puts "In learning you will teach, and in teaching you will learn. ― Phil Collins"

#Create demo academic history content
@students.each do |s|
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
puts "I go to school, but I never learn what I want to know. ― Calvin & Hobbes"

# Add array of faculty ids into each course config hash
# :staff_ids => [25,27]
@courses.each do |name,config|
  config[:staff_ids] = config[:course].staff.map { |staff| staff.id }
end


# If course has badges, create badges and add earned badges to students
@courses.each do |course_name,config|
  if config[:attributes][:badge_setting]
    config[:course].tap do |course|
      badge_names = config[:badge_names] || @course_default_config[:badge_names]
      badge_names.each do |badge_name|
        course.badges.create! do |b|
          b.name = badge_name
          b.point_total = 100 * rand(10)
          b.description = "A taste of glory trueborn, wolf night's watch, cell ever vigilant servant magister ut labore et dolore magna aliqua. Dirk we light the way, he asked too many questions flagon dwarf poison is a woman's weapon. Always pays his debts old bear court let me soar sorcery the last of the dragons. Green dreams holdfast none so wise, spare me your false courtesy no foe may pass the wall."
          b.visible = true
          b.can_earn_multiple_times = [true,false].sample
          config[:badges][badge_name] = b
        end
      end
      puts_success :course, course_name, :badges_created

      course.badges.each do |badge|
        times_earned = 1
        if badge.can_earn_multiple_times?
          times_earned = [1,1,2,3].sample
        end
        @students.each do |student|
          n = [1, 2, 3, 4, 5].sample
          if n.even?
            times_earned.times do
              student.earned_badges.create! do |eb|
                eb.badge = badge
                eb.course = course
                eb.student_visible = true
                eb.feedback = "Now what are the possibilities of warp drive? Cmdr Riker's nervous system has been invaded by an unknown microorganism. The organisms fuse to the nerve, intertwining at the molecular level. That's why the transporter's biofilters couldn't extract it. The vertex waves show a K-complex corresponding to an REM state. The engineering section's critical. Destruction is imminent. Their robes contain ultritium, highly explosive, virtually undetectable by your transporter."
              end
            end
          end
        end
      end
    end
  end
end

# Create Assignment Types!

#----------------------------------------------------------------------------------------------------------------------#

#                                     ASSIGNMENT TYPE DEFAULT CONFIGURATION                                            #

#----------------------------------------------------------------------------------------------------------------------#


# Add all attributes that will be passed on any assignment type creation here, with a default value
# All assignment types will use defaults when individual attributes aren't supplied

@assignment_type_default_config = {
  :quotes => {
    :assignment_type_created => "A new assignment type for each course has been created"
  },
  :attributes => {
    :name => "Genric Assignment Type",
    :description => nil,
    :max_points => nil,
    :position => nil,
    :student_weightable => false,
  }
}

#----------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------#

# Create Assignment Types!
@assignment_types = {}

# Define Assignment Types, override default values

@assignment_types[:grading] = {
  :quotes => {
    :assignment_type_created => "Well, I gotta look on the bright side. Maybe I can still get kicked out of school. - Buffy"
  },
  :attributes => {
    :name => "Grading Settings",
    :description => "This category should include all of the different ways assignments can be graded.",
    :position => 1
  }
}

@assignment_types[:submissions] = {
  :quotes => {
    :assignment_type_created => "Creativity is the process of having original ideas that have value. It is a process; it's not random. - Sir Ken Robinson"
  },
  :attributes => {
    :name => "Submission Settings",
    :description => "This category includes all of the different ways that assignments can handle submissions.",
    :position => 2
  }
}

@assignment_types[:predictor] = {
  :quotes => {
    :assignment_type_created => "Beware of overconfidence; especially in matters of structure. – Cass Gilbert"
  },
  :attributes => {
    :name => "Predictor Settings",
    :description => "This category includes all of the different ways that assignments can handle submissions.",
    :position => 3
  }
}

@assignment_types[:visibility] = {
  :quotes => {
    :assignment_type_created => "A different voice may be particularly effective in disturbing the existing participants into re-examining matters they had come to take for granted. ― Stefan Collini"
  },
  :attributes => {
    :name => "Visibility Settings",
    :description => "This category includes checks for visibile and not-visible assignments",
    :position => 4
  }
}

@assignment_types[:capped] = {
  :quotes => {
    :assignment_type_created => nil
  },
  :attributes => {
    :name => "Assignment Type with a Capped Point Total",
    :description => "This category includes checks for when the assignment type caps the total points",
    :max_points => 100000,
    :position => 5
  }
}

@assignment_types[:notifications] = {
  :quotes => {
    :assignment_type_created => "Play is our brain's favorite way of learning. – Diane Ackerman"
  },
  :attributes => {
    :name => "Notification Settings",
  }
}

@assignment_types[:analytics] = {
  :quotes => {
    :assignment_type_created => "People want to forget the impossible. It makes their world safer. ― Neil Gaiman"
  },
  :attributes => {
    :name => "Analytics Settings",
  }
}

@assignment_types[:unlocks] = {
  :quotes => {
    :assignment_type_created => "Life's under no obligation to give us what we expect. ― Margaret Mitchell"
  },
  :attributes => {
    :name => "Unlock Settings",
  }
}

@assignment_types[:sorting] = {
  :quotes => {
    :assignment_type_created => "Every maker of video games knows something that the makers of curriculum don't seem to understand. You'll never see a video game being advertised as being easy. Kids who do not like school will tell you it's not because it's too hard. It's because it's--boring ― Seymour Papert"
  },
  :attributes => {
    :name => "Sorting Settings",
  }
}

@assignment_types[:weighting_one] = {
  :quotes => {
    :assignment_type_created => nil,
  },
  :attributes => {
    :name => "Weighted Assignment Type #1 Settings",
    :student_weightable => true,
  }
}

@assignment_types[:weighting_two] = {
  :quotes => {
    :assignment_type_created => nil,
  },
  :attributes => {
    :name => "Weighted Assignment Type #2 Settings",
    :student_weightable => true,
  }
}

@assignment_types[:weighting_three] = {
  :quotes => {
    :assignment_type_created => nil,
  },
  :attributes => {
    :name => "Weighted Assignment Type #3 Settings",
    :student_weightable => true,
  }
}

@assignment_types[:weighting_four] = {
  :quotes => {
    :assignment_type_created => nil,
  },
  :attributes => {
    :name => "Weighted Assignment Type #3 Settings",
    :student_weightable => true,
  }
}

@assignment_types.each do |assignment_type_name,config|
  @courses.each do |course_name,course_config|
    next if (config[:attributes][:student_weightable] == true) && (! course_config[:attributes].has_key?(:total_assignment_weight))
    course_config[:course].tap do |course|
      assignment_type = AssignmentType.create! do |at|
        @assignment_type_default_config[:attributes].keys.each do |attr|
          at[attr] = config[:attributes][attr] || @assignment_type_default_config[:attributes][attr]
        end
        at.course = course
      end
      # Store models on each course in the @courses hash
      @courses[course_name][:assignment_types][assignment_type_name] = assignment_type
    end
  end
  puts_success :assignment_type, assignment_type_name, :assignment_type_created
end


#----------------------------------------------------------------------------------------------------------------------#

#                                          ASSIGNMENT DEFAULT CONFIGURATION                                            #

#----------------------------------------------------------------------------------------------------------------------#

# Add all attributes that will be passed on any assignment creation here, with a default value
# All assignments will use defaults when individual attributes aren't supplied

@assignment_default_config = {
  :quotes => {
    :assignment_created => "A new assignment for each course has been created",
    :grades_created => "Grades were created for the assignment",
    :submissions_created => "Submissions were created for the assignment",
    :rubric_created => "A Rubric was created for the assignment",
    :score_levels_created => "Score levels were created for the assignment"
  },
  :assignment_type => :grading,
  :attributes => {
    # main attributes:
    :name => "Generic Assignment",
    :open_at => nil,
    :due_at => nil,
    :point_total => 5000,
    # additional attributes:
    :accepts_attachments => false,
    :accepts_links => false,
    :accepts_submissions => false,
    :accepts_text => false,
    :description => nil,
    :grade_scope => "Individual",
    :hide_analytics => nil,
    :mass_grade_type => nil,
    :notify_released => false,
    :points_predictor_display => nil,
    :release_necessary => false,
    :student_logged => false,
    :visible => true,
  },
  :grades => false,
  # only used if :grades is true:
  :grade_attributes => {
    :raw_score => Proc.new { rand(5000) },
    :instructor_modified => true,
    :status => nil,
    :predicted_score => Proc.new { 0 },
  },
  :assignment_score_levels => false,
  :rubric => true,
  :student_submissions => true,
  :unlock_condition => false,
  :unlock_attributes => {
    :condition => :nil,
    :condition_type => nil,
    :condition_state => nil
  }
}

#----------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------#

# Create Assignments!
@assignments = {}

# Add each assignment below, override default configuration for custom attributes

@assignments[:standard_edit_quick_grade_text] = {
  :quotes => {
    :assignment_created => "Study hard what interests you the most in the most undisciplined, irreverent and original manner possible. ― Richard Feynman"
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Standard Edit + Quick Grade with Text Box [No grades]",
    :open_at => 1.weeks.from_now,
    :due_at => 1.weeks.from_now + 0.05,

  }
}

@assignments[:standard_edit_quick_grade_text_graded] = {
  :quotes => {
    :assignment_created => "We demand rigidly defined areas of doubt and uncertainty! - Douglas Adams"
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Standard Edit + Quick Grade with Text Box [Grades]",
    :open_at => 1.weeks.from_now,
    :due_at => 1.weeks.from_now + 0.05,

  },
  :grades => true,
  :grade_attributes => {
    :status => "Graded",
  }
}

@assignments[:standard_edit_quick_grade_checkbox] = {
  :quotes => {
    :assignment_created => "For me, I am driven by two main philosophies: know more today about the world than I knew yesterday and lessen the suffering of others. You'd be surprised how far that gets you. ― Neil deGrasse Tyson"
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Standard Edit + Quick Grade with Checkbox [No Grades]",
    :open_at => 2.weeks.ago,
    :due_at => 2.weeks.ago + 0.05,
    :mass_grade_type => "Checkbox",
  }
}

@assignments[:standard_edit_quick_grade_checkbox_graded] = {
  :quotes => {
    :assignment_created => "I hope you're pleased with yourselves. We could all have been killed - or worse, expelled. Now if you don't mind, I'm going to bed. ― J.K. Rowling"
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Standard Edit + Quick Grade with Checkbox [Grades]",
    :open_at => 2.weeks.ago,
    :due_at => 2.weeks.ago + 0.05,
    :mass_grade_type => "Checkbox",
  },
  :grades => true,
  :grade_attributes => {
    :status => "Graded",
  }
}

@assignments[:standard_edit_quick_grade_select_assignment] = {
  :quotes => {
    :assignment_created => "What a school thinks about its library is a measure of what it feels about education.― Harold Howe",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Standard Edit with Select/Quick Grade with Select [No Grades]",
    :open_at => 2.weeks.ago,
    :due_at => 2.weeks.ago + 0.05,
    :mass_grade_type => "Select List",
    :point_total => 20000,
  },
  :assignment_score_levels => true,
}

@assignments[:standard_edit_quick_grade_select_assignment_graded] = {
  :quotes => {
    :assignment_created => "Education consists mainly of what we have unlearned.― Mark Twain, Notebook",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Standard Edit with Select/Quick Grade with Select [Grades]",
    :open_at => 2.weeks.ago,
    :due_at => 2.weeks.ago + 0.05,
    :mass_grade_type => "Select List",
    :point_total => 20000,
  },
  :assignment_score_levels => true,
  :grades => true,
  :grade_attributes => {
    :status => "Graded",
  }
}

@assignments[:self_log_boolean_assignment] = {
  :quotes => {
    :assignment_created => "It's not that I feel that school is a good idea gone wrong, but a wrong idea from the word go. It's a nutty notion that we can have a place where nothing but learning happens, cut off from the rest of life.― John Holt",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Single-level Self-Logged Assignment [No Grades]",
    :open_at => DateTime.now,
    :due_at => DateTime.now + 0.05,
    :student_logged => true,
  }
}

@assignments[:self_log_boolean_assignment_graded] = {
  :quotes => {
    :assignment_created => "School should be the best party in town ― Peter Kline",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Single-level Self-Logged Assignment [Grades]",
    :open_at => DateTime.now,
    :due_at => DateTime.now + 0.05,
    :student_logged => true,
  },
  :grades => true,
  :grade_attributes => {
    :status => "Graded",
  }
}

@assignments[:self_log_score_level_assignment] = {
  :quotes => {
    :assignment_created => "I didn't give it much thought back then. I just wanted to get all the words straight and collect my A. ― Gayle Forman, Just One Day",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Multi-level Self-Logged Assignment",
    :open_at => DateTime.now,
    :due_at => DateTime.now + 0.05,
    :point_total => 200000,
    :student_logged => true,
  },
  :assignment_score_levels => true,
}

@assignments[:standard_edit_release_required] = {
  :quotes => {
    :assignment_created => "But what are schools for if not to make children fall so deeply in love with the world that they really want to learn about it? That is the true business of schools. And if they succeed in it, all other desirable developments follow of themselves. - Marjorie Spock",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Standard Edit + Release Required",
    :open_at => 3.weeks.from_now,
    :due_at => 3.weeks.from_now + 0.05,
    :release_necessary => true
  }
}

@assignments[:rubric_assignment] = {
  :quotes => {
    :assignment_created => "We spend the first year of a child's life teaching it to walk and talk and the rest of its life to shut up and sit down. There's something wrong there. ― Neil deGrasse Tyson",
    :rubric_created => "What is this? A center for ants? How can we be expected to teach children to learn how to read... if they can't even fit inside the building? --Derek Zoolander",
    :submissions_created => "I was the intellectual equivalent of a 98-pound weakling! I would go to the beach and people would kick copies of Byron in my face! - John Keating",
    :grade_created => "Volumetric flask is for general mixing and titration. You wouldn't apply heat to a volumetric flask. That's what a boiling flask is for. Did you learn nothing from my chemistry class? - Walter H. White",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Rubric Graded Assignment",
    :open_at => 4.weeks.ago,
    :due_at => 3.weeks.ago,
    :point_total => 80000,
    :accepts_submissions => true,
    :release_necessary => true,
  },
  :grades => true,
  :grade_attributes => {
    :status => "Graded",
  },
  :rubric => true,
  :student_submissions => true
}

@assignments[:group_grade_assignment] = {
  :quotes => {
    :assignment_created => "I'm sorry, if you were right, I'd agree with you. - Robin Williams",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Group Assignment + Standard Edit",
    :open_at => 3.weeks.ago,
    :due_at => 3.weeks.ago + 0.05,
    :point_total => 10000,
    :grade_scope => "Group"
  }
}

@assignments[:group_grade_submissions_assignment] = {
  :quotes => {
    :assignment_created => "Many highly talented, brilliant, creative people think they're not - because the thing they were good at at school wasn't valued, or was actually stigmatized. - Sir Ken Robinson",
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Group Assignment + Submissions",
    :due_at => 2.weeks.ago + 0.05,
    :point_total => 15000,
    :grade_scope => "Group"
  }
}

@assignments[:group_grade_rubric_assignment] = {
  :quotes => {
    :assignment_created => "It does not matter how slowly you go as long as you do not stop.― Confucius",
    :rubric_created => "They learn to unlearn, To redeem the fault of the people, To assist the nature of all things, Without daring to meddle. - Lao Tzu"
  },
  :assignment_type => :grading,
  :attributes => {
    :name => "Group Assignment + Rubric Edit",
    :due_at => 1.weeks.ago,
    :point_total => 15000,
    :grade_scope => "Group"
  },
  :rubric => true
}

@assignments[:no_submissions_assignment] = {
  :quotes => {
    :assignment_created => "The answer is not to standardize education, but to personalize and customize it to the needs of each child and community. There is no alternative. There never was. –Ken Robinson",
  },
  :assignment_type => :submissions,
  :attributes => {
    :name => "Assignment Does Not Accept Submissions",
    :open_at => 2.weeks.ago,
    :due_at => DateTime.now + 0.05,
    :point_total => 200000,
    :accepts_submissions => false,
  }
}

@assignments[:accepts_submissions_assignment] = {
  :quotes => {
    :assignment_created => "One recipe for one kind of fun: 1) Identify the inherent learnable challenge, 2) Restructure it optimally with clear goals, rules, and feedback, 3) Playtest and iterate – Sebastian Deterding",
  },
  :assignment_type => :submissions,
  :attributes => {
    :name => "Assignment Accepts All Types of Submissions",
    :due_at => DateTime.now + 0.25,
    :point_total => 200000,
    :accepts_submissions => true,
  }
}

@assignments[:accepts_link_submissions_assignment] = {
  :quotes => {
    :assignment_created => "Good design is a lot like clear thinking made visual. – Edward Tufte",
  },
  :assignment_type => :submissions,
  :attributes => {
    :name => "Assignment Accepts Link Submissions",
    :due_at => DateTime.now + 0.25,
    :point_total => 15000,
    :accepts_attachments => false,
    :accepts_links => true,
    :accepts_submissions => true,
    :accepts_text => false,
  }
}

@assignments[:accepts_attachment_submissions_assignment] = {
  :quotes => {
    :assignment_created => "Design is where science and art break even. – Robin Mathew",
  },
  :assignment_type => :submissions,
  :attributes => {
    :name => "Assignment Accepts Attachment Submissions",
    :due_at => DateTime.now + 0.25,
    :point_total => 15000,
    :accepts_attachments => true,
    :accepts_links => false,
    :accepts_submissions => true,
    :accepts_text => false,
  }
}

@assignments[:accepts_text_submissions_assignment] = {
  :quotes => {
    :assignment_created => "I think constraints are very important. They're positive, because they allow you to work off something. – Charles Gwathmey",
  },
  :assignment_type => :submissions,
  :attributes => {
    :name => "Assignment Accepts Text Submissions",
    :due_at => DateTime.now + 0.25,
    :point_total => 15000,
    :accepts_attachments => false,
    :accepts_links => false,
    :accepts_submissions => true,
    :accepts_text => true,
  }
}

@assignments[:predictor_with_graded_grade_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment is Past with Grade",
    :due_at => 1.week.ago,
    :point_total => 15000,
    :points_predictor_display => "Slider",
  },
  :grades => true,
  :grade_attributes => {
    :instructor_modified => true,
    :predicted_score => Proc.new { rand(15000) },
    :status => "Graded"
  }
}

@assignments[:predictor_past_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment is Past with no Grade",
    :due_at => 1.week.ago,
    :point_total => 15000,
    :points_predictor_display => "Slider",
  }
}

@assignments[:predictor_past_with_unreleased_grade_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment is Past with Unreleased Grade",
    :due_at => 1.week.ago,
    :point_total => 15000,
    :points_predictor_display => "Slider",
    :release_necessary => true,
  },
  :grades => true,
  :grade_attributes => {
    :instructor_modified => true,
    :predicted_score => Proc.new { rand(15000) },
    :status => "Graded"
  }
}

@assignments[:predictor_fixed_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment Shows Switch in Predictor",
    :due_at => 1.week.from_now,
    :point_total => 15000,
    :points_predictor_display => "Fixed",
  }
}

@assignments[:predictor_fixed_assignment_predicted] = {
  :quotes => {
    :assignment_created => "The whole educational and professional training system is a very elaborate filter, which just weeds out people who are too independent, and who think for themselves, and who don't know how to be submissive, and so on -- because they're dysfunctional to the institutions. ― Noam Chomsky",
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment Shows Predicted Positive Switch in Predictor",
    :due_at => 1.week.from_now,
    :point_total => 15000,
    :points_predictor_display => "Fixed",
  },
  :grades => true,
  :grade_attributes => {
    :instructor_modified => false,
    :raw_score => Proc.new { nil },
    :predicted_score => Proc.new { rand(15000) },
  }
}

@assignments[:predictor_continuous_slider_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment Shows Slider (no levels) in Predictor",
    :due_at => 1.week.from_now,
    :point_total => 15000,
    :points_predictor_display => "Slider"
  }
}

@assignments[:predictor_continuous_slider_assignment_predicted] = {
  :quotes => {
    :assignment_created => "We are students of words: we are shut up in schools, and colleges, and recitation -rooms, for ten or fifteen years, and come out at last with a bag of wind, a memory of words, and do not know a thing. ― Ralph Waldo Emerson",
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment Shows Slider (no levels) in Predictor",
    :due_at => 1.week.from_now,
    :point_total => 15000,
    :points_predictor_display => "Slider",
  },
  :grades => true,
  :grade_attributes => {
    :instructor_modified => false,
    :raw_score => Proc.new { nil },
    :predicted_score => Proc.new { rand(15000) },
  }
}

@assignments[:predictor_slider_with_levels_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment Shows Slider with Levels in Predictor [Not Graded]",
    :due_at => 1.week.from_now,
    :point_total => 25000,
    :points_predictor_display => "Slider",
  },
  :assignment_score_levels => true
}

@assignments[:predictor_slider_with_levels_assignment_graded] = {
  :quotes => {
    :assignment_created => "What's gotten in the way of education in the United States is a theory of social engineering that says there is ONE RIGHT WAY to proceed with growing up. ― John Taylor Gatto",
  },
  :assignment_type => :predictor,
  :attributes => {
    :name => "Assignment Shows Slider with Levels in Predictor [Graded]",
    :due_at => 1.week.from_now,
    :point_total => 25000,
    :points_predictor_display => "Slider",
  },
  :assignment_score_levels => true,
  :grades => true,
  :grade_attributes => {
    :instructor_modified => false,
    :raw_score => Proc.new { nil },
    :predicted_score => Proc.new { rand(25000) },
  }
}

@assignments[:invisible_assignment] = {
  :quotes => {
    :assignment_created => "Invisible Learning is a recognition that most of the learning we do is “invisible” – that is, it is through informal, non-formal, and serendipitous experiences rather than through formal instruction. --  John Moravec",
  },
  :assignment_type => :visibility,
  :attributes => {
    :name => "I'm an Invisible Assignment",
    :due_at => 2.weeks.from_now,
    :point_total => 15000,
    :visible => false,
  }
}

@assignments[:visible_assignment] = {
  :quotes => {
    :assignment_created => "College: two hundred people reading the same book. An obvious mistake. Two hundred people can read two hundred books. ― John Cage",
  },
  :assignment_type => :visibility,
  :attributes => {
    :name => "Hey, I'm a Visible Assignment!",
    :due_at => 2.weeks.from_now,
    :point_total => 15000,
    :visible => true,
  }
}

@assignments[:with_more_points_than_atype_cap] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :capped,
  :attributes => {
    :name => "Assignment with More Points than the Max Value for the Assignment Type",
    :due_at => 3.weeks.from_now,
    :point_total => 150000,
  }
}

@assignments[:sends_email_notes_on_release] = {
  :quotes => {
    :assignment_created => "People tend to forget that play is serious. – David Hockney",
  },
  :assignment_type => :notifications,
  :attributes => {
    :name => "Grade Triggers Email",
    :description => "I send out emails when student receives a grade",
    :due_at => 4.weeks.from_now,
    :point_total => 150000,
    :release_necessary => true,
    :notify_released => true,
  }
}

@assignments[:sends_email_notes_immediately] = {
  :quotes => {
    :assignment_created => "Do not keep children to their studies by compulsion but by play. – Plato",
  },
  :assignment_type => :notifications,
  :attributes => {
    :name => "Grades Released Triggers Email",
    :description => "I send out emails when grades are released",
    :due_at => 4.weeks.from_now,
    :point_total => 150000,
    :release_necessary => false,
    :notify_released => true,
  }
}

@assignments[:does_not_send_emails] = {
  :quotes => {
    :assignment_created => "You're always you, and that don't change, and you're always changing, and there's nothing you can do about it. ― Neil Gaiman",
  },
  :assignment_type => :notifications,
  :attributes => {
    :name => "No Emails Assignment",
    :description => "I do not send out email notifications to students",
    :due_at => 4.weeks.from_now,
    :point_total => 150000,
    :release_necessary => false,
    :notify_released => false,
  }
}

@assignments[:analytics_on] = {
  :quotes => {
    :assignment_created => "The saddest aspect of life right now is that science gathers knowledge faster than society gathers wisdom. ― Isaac Asimov",
  },
  :assignment_type => :analytics,
  :attributes => {
    :name => "Indvidual Assignment + Analytics",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
    :hide_analytics => false,
  }
}

@assignments[:groups_analytics_on] = {
  :quotes => {
    :assignment_created => "Of all sad words of tongue or pen, the saddest are these, 'It might have been.' ― John Greenleaf Whittier",
  },
  :assignment_type => :analytics,
  :attributes => {
    :name => "Group Assignment + Analytics",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
    :hide_analytics => false,
    :grade_scope => "Group",
  }
}

@assignments[:hidden_analytics_on] = {
  :quotes => {
    :assignment_created => "People aren't either wicked or noble. They're like chef's salads, with good things and bad things chopped and mixed together in a vinaigrette of confusion and conflict. ― Lemony Snicket",
  },
  :assignment_type => :analytics,
  :attributes => {
    :name => "Indvidual Assignment + Hidden Analytics",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
    :hide_analytics => true,
  }
}

@assignments[:groups_hidden_analytics_on] = {
  :quotes => {
    :assignment_created => "Life can only be understood backwards; but it must be lived forwards. ― Soren Kierkegaard",
  },
  :assignment_type => :analytics,
  :attributes => {
    :name => "Group Assignment + Hidden Analytics",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
    :hide_analytics => true,
    :grade_scope => "Group",
  }
}

@assignments[:badge_is_an_unlock] = {
  :quotes => {
    :assignment_created => "Badges, to g**-d***** h*** with badges! We have no badges. In fact, we don’t need badges. I don't have to show you any stinking badges, you g**-d***** cabron and c****’ tu madre! – B. Traven",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlocked-By-Badge-Example",
    :description => "Earning a Badge unlocks this assignment.",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
  },
  :unlock_condition => true,
  :unlock_attributes => {
    :condition => :unlock_submission_condition,
    :condition_type => "Badge",
    :condition_state => "Earned"
  }
}

@assignments[:unlock_submission_condition] = {
  :quotes => {
    :assignment_created => "Now, it is the view of the Ministry that a theoretical knowledge will be more than sufficient to get you through your examination, which, after all, is what school is all about. ― J.K. Rowling",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Submission-Key",
    :description => "I'm the thing you need to submit to unlock 'Unlocked-By-Submission'",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
    :accepts_submissions => true,
  }
}

@assignments[:submission_is_an_unlock] = {
  :quotes => {
    :assignment_created => "School has become the world religion of a modernized proletariat, and makes futile promises of salvation to the poor of the technological age. ― Ivan Illich",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlocked-By-Submission",
    :description => "Submitting 'Submission-Key' unlocks this assignment",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
  },
  :unlock_condition => true,
  :unlock_attributes => {
    :condition => :unlock_submission_condition,
    :condition_type => "Assignment",
    :condition_state => "Submitted"
  }
}

@assignments[:unlock_grade_earned_condition] = {
  :quotes => {
    :assignment_created => "In all the works on pedagogy that ever I read — and they have been many, big, and heavy — I don't remember that any one has advocated a system of teaching by practical jokes, mostly cruel. That, however, describes the method of our great teacher, Experience. ― Charles Sanders Peirce",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlock-Grade-Earned-Key",
    :description => "I'm the thing you need to earn a grade on to unlock 'Unlocked-By-Grade-Earned'",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
  }
}

@assignments[:grade_earned_is_an_unlock] = {
  :quotes => {
    :assignment_created => "The public has a distorted view of science because children are taught in school that science is a collection of firmly established truths. In fact, science is not a collection of truths. It is a continuing exploration of mysteries. ― Freeman Dyson",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlocked-By-Grade-Earned",
    :description => "Earning a Grade for 'Unlock-Grade-Earned-Key' unlocks this one",
    :due_at => 2.weeks.ago + 0.05,
  },
  :unlock_condition => true,
  :unlock_attributes => {
    :condition => :unlock_grade_earned_condition,
    :condition_type => "Assignment",
    :condition_state => "Grade Earned"
  }
}

@assignments[:unlock_grade_earned_by_date_condition] = {
  :quotes => {
    :assignment_created => "The 'polymath' had already died out by the close of the eighteenth century, and in the following century intensive education replaced extensive, so that by the end of it the specialist had evolved. The consequence is that today everyone is a mere technician, even the artist... ― Dietrich Bonhoeffer",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlock-Grade-Earned-By-Date-Key",
    :description => "I'm the thing you need to earn a grade on by a date to unlock 'Unlocked-By-Grade-Earned-By-Date'",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
  }
}

@assignments[:grade_earned_by_date_is_an_unlock] = {
  :quotes => {
    :assignment_created => "Placing the burden on the individual to break down doors in finding better education for a child is attractive to conservatives because it reaffirms their faith in individual ambition and autonomy. But to ask an individual to break down doors that we have chained and bolted in advance of his arrival is unfair. ― Jonathan Kozol",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlocked-By-Grade-Earned",
    :description => "Earning a Grade for 'Unlock-Grade-Earned-By-Date-Key' unlocks this",
    :due_at => 2.weeks.ago + 0.05,
  },
  :unlock_condition => true,
  :unlock_attributes => {
    :condition => :unlock_grade_earned_by_date_condition,
    :condition_type => "Assignment",
    :condition_state => "Grade Earned",
    :condition_date => 1.week.ago
  }
}

@assignments[:unlock_feedback_read_condition] = {
  :quotes => {
    :assignment_created => "Generally in life, knowledge is acquired to be used. But school learning more often fits Freire's apt metaphor: knowledge is treated like money, to be put away in a bank for the future. ― Seymour Papert",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlock-Feedback-Read-Key",
    :description => "I'm the thing you need to read the feedback on to unlock 'Unlocked-By-Feedback-Read'",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
  }
}

@assignments[:feedback_read_is_an_unlock] = {
  :quotes => {
    :assignment_created => "To explain something to someone is first of all to show him he cannot understand it by himself. ― Jacques Rancière",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlocked-By-Feedback-Read",
    :description => "Reading the Feedback on 'Unlock-Feedback-Read-Key' unlocks this",
    :due_at => 2.weeks.ago + 0.05,
  },
  :unlock_condition => true,
  :unlock_attributes => {
    :condition => :unlock_feedback_read_condition,
    :condition_type => "Assignment",
    :condition_state => "Feedback Read",
  }
}

@assignments[:unlock_feedback_read_by_date_condition] = {
  :quotes => {
    :assignment_created => "Grandma calls it the Socratic Method. She considers it the highest pedagogical technique. I call it cornering a person. Instead of just telling you what I want you to know, I ambush you with questions. You try to escape, but you can’t. You can run whichever way you like, but in the end you’ll fall right into my trap. ― Sophia Nikolaidou",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlock-Feedback-Read-By-Date-Key",
    :description => "I'm the thing you need to read the feedback on by a date to unlock 'Unlocked-By-Feedback-Read-By-Date'",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
  }
}

@assignments[:feedback_read_by_date_is_an_unlock] = {
  :quotes => {
    :assignment_created => "school people must not fall into the trap of thinking that early preparation for an unjust world requires early exposure to injustice ― Oakes Jeannie",
  },
  :assignment_type => :unlocks,
  :attributes => {
    :name => "Unlocked-By-Feedback-Read-By-Date",
    :description => "Reading the Feedback on 'Unlock-Feedback-Read-By-Date-Key' Unlocks this",
    :due_at => 4.weeks.from_now,
    :point_total => 180000,
  },
  :unlock_condition => true,
  :unlock_attributes => {
    :condition => :unlock_feedback_read_by_date_condition,
    :condition_type => "Assignment",
    :condition_state => "Feedback Read",
    :condition_date => 1.week.ago
  }
}

@assignments[:alphanum_1_condition] = {
  :quotes => {
    :assignment_created => "In a classical joke a child stays behind after school to ask a personal question. 'Teacher, what did I learn today?' The surprised teacher asks, 'Why do you ask that?' and the child replies, 'Daddy always asks me and I never know what to say.' ― Seymour Papert",
  },
  :assignment_type => :sorting,
  :attributes => {
    :name => "Class 1",
    :description => "Tests that Assignments are Sorted Correctly by Alphanumeric Name"
  }
}

@assignments[:alphanum_2_condition] = {
  :quotes => {
    :assignment_created => "Nothing bothers me more than when people criticize my criticism of school by telling me that schools are not just places to learn maths and spelling, they are places where children learn a vaguely defined thing called socialization. I know. I think schools generally do an effective and terribly damaging job of teaching children to be infantile, dependent, intellectually dishonest, passive and disrespectful to their own developmental capacities. - Seymour Papert",
  },
  :assignment_type => :sorting,
  :attributes => {
    :name => "Class 2",
    :description => "Tests that Assignments are Sorted Correctly by Alphanumeric Name"
  }
}

@assignments[:alphanum_12_condition] = {
  :quotes => {
    :assignment_created => "School is the advertising agency which makes you believe that you need the society as it is. ― Ivan Illich",
  },
  :assignment_type => :sorting,
  :attributes => {
    :name => "Class 12",
    :description => "Tests that Assignments are Sorted Correctly by Alphanumeric Name"
  }
}

@assignments[:alphanum_10_condition] = {
  :quotes => {
    :assignment_created => "Most learning is not the result of instruction. It is rather the result of unhampered participation in a meaningful setting. Most people learn best by being 'with it,' yet school makes them identify their personal, cognitive growth with elaborate planning and manipulation. ― Ivan Illich",
  },
  :assignment_type => :sorting,
  :attributes => {
    :name => "Class 10",
    :description => "Tests that Assignments are Sorted Correctly by Alphanumeric Name"
  }
}

@assignments[:alphanum_20_condition] = {
  :quotes => {
    :assignment_created => "Formal learning is like riding a bus: the driver decides where the bus is going; the passengers are along for the ride. Informal learning is like riding a bike: the rider chooses the destination, the speed, and the route.― Jay Cross",
  },
  :assignment_type => :sorting,
  :attributes => {
    :name => "Class 20",
    :description => "Tests that Assignments are Sorted Correctly by Alphanumeric Name"
  }
}

@assignments[:weighting_one_sample_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :weighting_one,
  :attributes => {
    :name => "Weighted Assignment Type 1",
    :point_total => 50000,
    :due_at => 4.weeks.from_now,
  }
}

@assignments[:weighting_two_sample_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :weighting_two,
  :attributes => {
    :name => "Weighted Assignment Type 2",
    :point_total => 50000,
    :due_at => 4.weeks.from_now,
  }
}

@assignments[:weighting_three_sample_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :weighting_three,
  :attributes => {
    :name => "Weighted Assignment Type 3",
    :point_total => 50000,
    :due_at => 4.weeks.from_now,
  }
}

@assignments[:weighting_four_sample_assignment] = {
  :quotes => {
    :assignment_created => nil,
  },
  :assignment_type => :weighting_four,
  :attributes => {
    :name => "Weighted Assignment Type 4",
    :point_total => 50000,
    :due_at => 4.weeks.from_now,
  }
}

@assignments.each do |assignment_name,config|
  @courses.each do |course_name,course_config|
    assignment_type_name = config[:assignment_type] || @assignment_default_config[:assignment_type]
    next if ! course_config[:assignment_types].has_key? assignment_type_name

    course_config[:course].tap do |course|

      # used to generate grades and score levels
      assignment_points_total = config[:attributes][:point_total] || @assignment_default_config[:attributes][:point_total]

      assignment = Assignment.create! do |a|
        @assignment_default_config[:attributes].keys.each do |attr|
          # ternary allows override for visible ('true' by default)
          a[attr] = config[:attributes].has_key?(attr) ? config[:attributes][attr] : @assignment_default_config[:attributes][attr]
        end
        a.assignment_type = course_config[:assignment_types][assignment_type_name]
        a.course = course
      end
      course_config[:assignments][assignment_name] = assignment

      if config[:rubric]
        Rubric.create! do |rubric|
          rubric.assignment = assignment
          rubric.save
          1.upto(15).each do |n|
            rubric.metrics.create! do |metric|
              metric.name = "Criteria ##{n}"
              metric.max_points = 10.times.collect {|i| (i + 1) * 10000}.sample
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
        print "." if ! course_name == @courses.keys[-1]
        puts_success :assignment, assignment_name, :rubric_created if course_name == @courses.keys[-1]
      end

      if config[:assignment_score_levels]
        1.upto(5).each do |n|
          assignment.assignment_score_levels.create! do |asl|
            asl.name = "Assignment Score Level ##{n}"
            asl.value = assignment_points_total/(6-n)
          end
        end
        puts_success :assignment, assignment_name, :score_levels_created if course_name == @courses.keys[-1]
      end

      if config[:student_submissions]
        @students.each do |student|
          submission = student.submissions.create! do |s|
            s.assignment = assignment
            s.text_comment = "Wingardium Leviosa"
            s.link = "http://www.twitter.com"
          end
          print "."
        end
        print "\n"
        puts_success :assignment, assignment_name, :submissions_created if course_name == @courses.keys[-1]
      end

      if config[:rubric] and config[:grades]
        @students.each do |student|
          assignment.rubric.metrics.each do |metric|
            metric.rubric_grades.create! do |rg|
              rg.max_points = metric.max_points
              rg.points = metric.tiers.first.points
              rg.tier = metric.tiers.first
              rg.metric_name = metric.name
              rg.tier_name = metric.tiers.first.name
              rg.assignment_id = assignment.id
              rg.order = 1
              rg.student_id = student.id
            end
          end
          print "."
        end
        print "\n"
        puts_success :assignment, assignment_name, :grades_created if course_name == @courses.keys[-1]


      elsif config[:grades]

        grade_attributes = config[:grade_attributes] || {}

        @students.each do |student|
          student.grades.create! do |g|
            @assignment_default_config[:grade_attributes].keys.each do |attr|

              # You can set a custom raw score in :grade_attributes like this:
              #   :raw_score => Proc.new { rand(20000) }
              # Defaults to a random number between 0 and assignment point total

              if (attr == :raw_score || attr == :predicted_score) && grade_attributes[attr]
                g[attr] = grade_attributes[attr].call
              elsif attr == :raw_score
                g[attr] = rand(assignment_points_total)
              elsif attr == :predicted_score
                g[attr] == 0
              else
                g[attr] = grade_attributes[attr] || @assignment_default_config[:grade_attributes][attr]
              end
              g.graded_by_id = course_config[:staff_ids].sample
            end
            g.assignment = assignment
          end
          print "."
        end
        print "\n"
        puts_success :assignment, assignment_name, :grades_created if course_name == @courses.keys[-1]
      end

      if config[:unlock_condition]
        # skip badge conditions when course is has no badge setting
        unless ( !course_config[:attributes][:badge_setting] && config[:unlock_attributes][:condition_type] == "Badge")
          assignment.unlock_conditions.create! do |uc|
            if config[:unlock_attributes][:condition_type] == "Assignment"
              uc.condition = course_config[:assignments][config[:unlock_attributes][:condition]]
            elsif config[:unlock_attributes][:condition_type] == "Badge"
              uc.condition = course_config[:badges][(course_config[:badge_names] || @course_default_config[:badge_names]).sample]
            end
            uc.condition_type = config[:unlock_attributes][:condition_type]
            uc.condition_state = config[:unlock_attributes][:condition_state]
            uc.condition_date = config[:unlock_attributes][:condition_date]
          end
        end
      end
    end # tap course
  end
  puts_success :assignment, assignment_name, :assignment_created
end

#----------------------------------------------------------------------------------------------------------------------#

#                                          CHALLENGE DEFAULT CONFIGURATION                                             #

#----------------------------------------------------------------------------------------------------------------------#

# Add all attributes that will be passed on any challenge creation here, with a default value
# All assignment types will use defaults when individual attributes aren't supplied


@challenge_default_config = {
  :quotes => {
    :challenge_created => "A challenge has been created for course with teams",
    :grades_created => "Grades were created for the challenge",
  },
  :attributes => {
    :name => "Generic Challenge",
    :open_at => nil,
    :due_at => nil,
    :point_total => 1000000,
    :accepts_submissions => false,
    :release_necessary => false,
    :visible => true,
  },
  :grades => false,
  :grade_attributes => {
    :score => Proc.new { rand(100000)},
    :status => nil,
  }
}

#----------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------#

# Create Challenges!
@challenges = {}

@challenges[:past_due] = {
  :quotes => {
    :challenge_created => nil,
    :grades_created => nil
  },
  :attributes => {
    :name => "Challenge in the Past",
    :due_at => 2.weeks.ago,
    :accepts_submissions => true,
  },
  :grades => true,
  :grade_attributes => {
    :status => "Graded",
  }
}

@challenges[:accepts_submissions] = {
  :quotes => {
    :challenge_created => nil
  },
  :attributes => {
    :name => "Challenge in the future that accepts submissions",
    :due_at => 2.weeks.from_now,
    :accepts_submissions => true,
    :open_at => rand(8).weeks.ago,
  }
}

@challenges[:requires_release] = {
  :quotes => {
    :challenge_created => nil
  },
  :attributes => {
    :name => "Challenge that Requires Release",
    :due_at => 3.weeks.from_now,
    :accepts_submissions => true,
    :open_at => rand(8).weeks.ago,
    :release_necessary => true
  }
}

@challenges[:invisible] = {
  :quotes => {
    :challenge_created => "Please don't ask me what the score is, I'm not even sure what the game is. - Ashleigh Brilliant"
  },
  :attributes => {
    :name => "Invisible Challenge",
    :due_at => 4.weeks.from_now,
    :accepts_submissions => true,
    :open_at => rand(8).weeks.ago,
    :visible => false,
  },
  :grades => true,
  :grade_attributes => {
    :status => "Graded",
  }
}

@challenges.each do |challenge_name,config|
  @courses.each do |course_name,course_config|
    next unless course_config[:attributes][:team_challenges]
    course_config[:course].tap do |course|
      challenge = Challenge.create! do |c|
        @challenge_default_config[:attributes].keys.each do |attr|
          c[attr] = config[:attributes].has_key?(attr) ? config[:attributes][attr] : @challenge_default_config[:attributes][attr]
        end
        c.course = course
      end
      # Store models on each course in the @courses hash
      @courses[course_name][:challenges][challenge_name] = challenge

      if config[:grades]
        # Used to set point total
        # You can also set a custom point total in the grade attributes:
        # :point_total => Proc.new { rand(20000) }
        grade_attributes = config[:grade_attributes] || {}
        assignment_points_total = config[:attributes][:point_total] || @challenge_default_config[:attributes][:point_total]

        course_config[:teams].each do |team|
          challenge.challenge_grades.create! do |cg|
            @challenge_default_config[:grade_attributes].keys.each do |attr|
              if attr == :score && grade_attributes[attr]
                cg[attr] = grade_attributes[attr].call
              elsif attr == :score
                cg[attr] = rand(assignment_points_total)
              else
                cg[attr] = grade_attributes[attr] || @challenge_default_config[:grade_attributes][attr]
              end
            end
            cg.team = team
          end
        end
      end
      puts_success :challenge, challenge_name, :grades_created
    end
  end
  puts_success :challenge, challenge_name, :challenge_created
end

@students.each do |s|
  s.courses.each do |c|
    s.cache_course_score(c.id)
  end
end
