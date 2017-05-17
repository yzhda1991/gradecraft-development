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
    created_at: Date.today,
    updated_at: Date.today,
    recipient_id: nil
  }
}

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

@announcements = {}

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
