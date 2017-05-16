# Events

  * Is a [customizable term](customizable terms)

### Concerns
  * [Copyable](copyable)
  * [UploadsMedia](uploads_media)

#### belongs_to
  * [Course](courses)

### Validations

  * boolean methods that must be set to either true or false: `name`

### Scopes

  * `with_dates`

### Attributes
  * `course_id`
  * `name`
  * `description`
  * `open_at`
  * `due_at`
  * `media`

### Google Calendar

#### Google Calendar Controller Methods

  * add_event_to_google_calendar - copies an event in the GradeCraft database to the user's primary Google Calendar.

#### Google Calendar Integration Set UP

1. Navigate to `https://console.developers.google.com/` and log in with your Google account. If you do not have a Google account, please create one now.
1. Click on the “Credentials” button in the left navigation pane.
1. In the “Select a Resource” box, select “Create”.
1. Choose a project name.
1. Agree to the terms and conditions.
1. Create an OAuth authorization.
1. Click on Configure Consent Screen button.
1. Fill out the form including Admin’s Email Address, Product Name, etc.
1. Add `http://localhost:5000` to the Authorized JavaScript Origins list.
1. Add `http://localhost:5000/auth/google_oauth2/callback` to the Authorized Redirect URIs.
1. Copy the Client Id and Client Secret from this page.
1. Add them to your environment variables in your project:
1. `GOOGLE_CLIENT_ID` = xyz…
1. `GOOGLE_SECRET` = xyz…
1. Navigate to “Library”
1. Find the API(s) you want to enable for your application in the list shown on the page.

   NOTE: It is mandatory to include the Google+ API. Please enable this API before any others.
1. Click on the link labeled “Enable API”.
1. Note the information for the API in the section “About this API”.
1. Click “Enable”.

#### UI Workflow

1. A user creates or views an event that has at minimum the following attributes:
	* name
	* open_at
	* due_at
1. The user clicks the `Add to Google Calendar` button.
1. If this is the user's first time using the `Add to Google Calendar` button, the user is directed to a Google Authorization page where the user will be given the option to allow or deny GradeCraft access to the user's primary Google Calendar.
1. Allowing GradeCraft access to the user's primary Google Calendar will in turn create a record in the `user_authorizations` table, with the `provider` field being `google_oauth2`. The user is then redirected back to the Events Index Page **WITHOUT** the event being added to the user's primary Google Calendar.
1. If the User denies GradeCraft access to the User's primary Google Calendar, then the user is directed to the `auth_failure.html` page.
1. If the user already has an existing `user_authorization` record where the provider is `google_oauth2`, then upon clicking the `Add to Google Calendar` button the `google_calendars_controller` will invoke the `google_calendars_helper` to refresh the `google_oauth2` `user_authorization` if it has expired.
1. If all checks pass, then the event is added to the user's primary Google Calendar.
1. For any reason, if there is an error then the user is redirected to the Events Page with the alert message, `Google Calendar encountered an Error. Your event was NOT copied to your Google calendar.`

#### Helpful Links

   * [Google Calendar V3 Class Documentation](http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/CalendarV3)
   * [Google Calendar V3 Event Class Documentation](http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/CalendarV3/Event)
   * [Google Calendar V3 CalendarSerive Class Documentation](http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/CalendarV3/CalendarService)
   * [Google Api Client Gem Documentation](https://github.com/google/google-api-ruby-client)
