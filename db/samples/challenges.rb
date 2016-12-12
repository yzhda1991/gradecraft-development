#------------------------------------------------------------------------------#

#                    CHALLENGE DEFAULT CONFIGURATION                           #

#------------------------------------------------------------------------------#

# Add all attributes that will be passed on any challenge creation here, with a
# default value
# All challenges will use defaults when individual attributes aren't
# supplied

@challenge_default_config = {
  quotes: {
    challenge_created: "A challenge has been created for course with teams",
    grades_created: "Grades were created for the challenge",
  },
  attributes: {
    name: "Generic Challenge",
    description: "Prefect’s bathroom Trelawney veela squashy armchairs, SPEW: Gamp’s Elemental Law of Transfiguration. Magic Nagini bezoar, Hippogriffs Headless Hunt giant squid petrified. Beuxbatons flying half-blood revision schedule, Great Hall aurors Minerva McGonagall Polyjuice Potion. Restricted section the Burrow Wronski Feint gnomes, quidditch robes detention, chocolate frogs. Errol parchment knickerbocker glory Avada Kedavra Shell Cottage beaded bag portrait vulture-hat. Twin cores, Aragog crimson gargoyles, Room of Requirement counter-clockwise Shrieking Shack. Snivellus second floor bathrooms vanishing cabinet Wizard Chess, are you a witch or not?",
    open_at: nil,
    due_at: nil,
    full_points: 100000,
    accepts_submissions: false,
    release_necessary: false,
    visible: true,
  },
  grades: false,
  grade_attributes: {
    raw_points: Proc.new { rand(10000)},
    status: nil,
  }
}

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

@challenges = {}

@challenges[:past_due] = {
  quotes: {
    challenge_created: nil,
    grades_created: nil
  },
  attributes: {
    name: "Challenge in the Past",
    due_at: 2.weeks.ago,
    accepts_submissions: true,
  },
  grades: true,
  grade_attributes: {
    status: "Graded",
  }
}

@challenges[:accepts_submissions] = {
  quotes: {
    challenge_created: nil
  },
  attributes: {
    name: "Challenge in the future that accepts submissions",
    due_at: 2.weeks.from_now,
    accepts_submissions: true,
    open_at: rand(8).weeks.ago,
  }
}

@challenges[:requires_release] = {
  quotes: {
    challenge_created: nil
  },
  attributes: {
    name: "Challenge that Requires Release",
    due_at: 3.weeks.from_now,
    accepts_submissions: true,
    open_at: rand(8).weeks.ago,
    release_necessary: true
  }
}

@challenges[:invisible] = {
  quotes: {
    challenge_created: "Please don't ask me what the score is, I'm not even \
sure what the game is. - Ashleigh Brilliant"
  },
  attributes: {
    name: "Invisible Challenge",
    due_at: 4.weeks.from_now,
    accepts_submissions: true,
    open_at: rand(8).weeks.ago,
    visible: false,
  },
  grades: true,
  grade_attributes: {
    status: "Graded",
  }
}
