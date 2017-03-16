1. Create the course in GradeCraft

2. Open the course in CTools. Copy and paste the course ID from the URL:

    /portal/site/**COURSE_ID**/page/PAGE_ID

1. Via the Rails console, set lti_uid to the course id.

1. In CTools, click GradeCraft in the sidebar (not sure if some setup is needed to get to that point). If you don't see the edit page, click the pencil icon in the top right.

1. Set configuration as follows:
    * Remote Tool URL: https://gradecraft.com/auth/lti/callback
    * Remote Tool Key: (same as `ENV['LTI_CONSUMER_KEY']` on server)
    * Remote Tool Secret: (same as `ENV['LTI_CONSUMER_SECRET']` on server)
    * Open in a new window: yes
    * Maximize window width: yes
    * Send names to external tool: yes
    * Allow the external tool to see the course roster: yes

1. Save settings, and then click the button to launch GradeCraft.
