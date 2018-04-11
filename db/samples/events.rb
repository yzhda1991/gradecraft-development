#------------------------------------------------------------------------------#

#                    EVENT DEFAULT CONFIGURATION                           #

#------------------------------------------------------------------------------#

# Add all attributes that will be passed on any event creation here, with a
# default value
# All events will use defaults when individual attributes aren't
# supplied

@event_default_config = {
  quotes: {
    event_created: "An event has been created",
  },
  attributes: {
    name: "Generic Event",
    open_at: nil,
    due_at: Date.today,
    description: nil
  }
}

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

@events = {}

@events[:past] = {
  quotes: {
    event_created: nil
  },
  attributes: {
    name: "Event in the Past",
    due_at: 2.weeks.ago,
    description: "Toad-like smile Flourish and Blotts he knew I’d come back Quidditch World Cup. Fat Lady baubles banana fritters fairy lights Petrificus Totalus. So thirsty, deluminator firs’ years follow me 12 inches of parchment. Head Boy start-of-term banquet Cleansweep Seven roaring lion hat. Unicorn blood crossbow mars is bright tonight, feast Norwegian Ridgeback. Come seek us where our voices sound, we cannot sing above the ground, Ginny Weasley bright red. Fanged frisbees, phoenix tears good clean match."
  }
}

@events[:future] = {
  quotes: {
    event_created: nil
  },
  attributes: {
    name: "Event in the Future",
    due_at: 2.weeks.from_now,
    open_at: rand(1..8).weeks.ago,
    description: "Boggarts lavender robes, Hermione Granger Fantastic Beasts and Where to Find Them. Bee in your bonnet Hand of Glory elder wand, spectacles House Cup Bertie Bott’s Every Flavor Beans Impedimenta. Stunning spells tap-dancing spider Slytherin’s Heir mewing kittens Remus Lupin. Palominos scarlet train black robes, Metamorphimagus Niffler dead easy second bedroom. Padma and Parvati Sorting Hat Minister of Magic blue turban remember my last."
  }
}

@events[:today] = {
  quotes: {
    event_created: nil
  },
  attributes: {
    name: "Event Today",
    open_at: rand(1..8).weeks.ago,
    description: "Thestral dirigible plums, Viktor Krum hexed memory charm Animagus Invisibility Cloak three-headed Dog. Half-Blood Prince Invisibility Cloak cauldron cakes, hiya Harry! Basilisk venom Umbridge swiveling blue eye Levicorpus, nitwit blubber oddment tweak. Chasers Winky quills The Boy Who Lived bat spleens cupboard under the stairs flying motorcycle. Sirius Black Holyhead Harpies, you’ve got dirt on your nose. Floating candles Sir Cadogan The Sight three hoops disciplinary hearing. Grindlewald pig’s tail Sorcerer's Stone biting teacup. Side-along dragon-scale suits Filch 20 points, Mr. Potter."
  }
}
