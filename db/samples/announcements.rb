#------------------------------------------------------------------------------#

#                    ANNOUNCEMENT DEFAULT CONFIGURATION                           #

#------------------------------------------------------------------------------#

# Add all attributes that will be passed on any announcement creation here, with a
# default value
# All announcements will use defaults when individual attributes aren't
# supplied

@announcement_default_config = {
  quotes: {
    announcement_created: "An announcement has been created",
  },
  attributes: {
    title: "Announcement Title",
    body: "Some body",
    # author_id: 3,
    # course_id: 1,
    created_at: Date.today,
    updated_at: Date.today,
    recipient_id: nil
  }
}

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

@announcements = {}

# @events[:past] = {
#   quotes: {
#     event_created: nil
#   },
#   attributes: {
#     name: "Event in the Past",
#     due_at: 2.weeks.ago,
#     description: "Toad-like smile Flourish and Blotts he knew I’d come back Quidditch World Cup. Fat Lady baubles banana fritters fairy lights Petrificus Totalus. So thirsty, deluminator firs’ years follow me 12 inches of parchment. Head Boy start-of-term banquet Cleansweep Seven roaring lion hat. Unicorn blood crossbow mars is bright tonight, feast Norwegian Ridgeback. Come seek us where our voices sound, we cannot sing above the ground, Ginny Weasley bright red. Fanged frisbees, phoenix tears good clean match."
#   }
# }
#
# @events[:future] = {
#   quotes: {
#     event_created: nil
#   },
#   attributes: {
#     name: "Event in the Future",
#     due_at: 2.weeks.from_now,
#     open_at: rand(8).weeks.ago,
#     description: "Boggarts lavender robes, Hermione Granger Fantastic Beasts and Where to Find Them. Bee in your bonnet Hand of Glory elder wand, spectacles House Cup Bertie Bott’s Every Flavor Beans Impedimenta. Stunning spells tap-dancing spider Slytherin’s Heir mewing kittens Remus Lupin. Palominos scarlet train black robes, Metamorphimagus Niffler dead easy second bedroom. Padma and Parvati Sorting Hat Minister of Magic blue turban remember my last."
#   }
# }

@announcements[:today] = {
  quotes: {
    announcement_created: nil
  },
  attributes: {
    title: "Announcement Today",
    body: "Dobbie is free",
    created_at: Date.today,
    updated_at: Date.today,
    recipient_id: nil
  }
}
