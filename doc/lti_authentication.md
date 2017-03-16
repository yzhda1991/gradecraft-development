## GradeCraft and LTI

  * Ctools used to use "Course Tools", in 2004 Sakai was introduced -- an open source standardization for course management. Ctools is the U of M instance of Sakai.
  * U of M is currently piloting Canvas, another LMS, which Gradecraft also supports.    

### Current Functionality

  1. Gradecraft works as a Tool Provider, and with a future enhancements, a Tool Consumer
  * The University LMS (Canvas) works as a Tool Consumer
  * We have, and continue to support Sakai as another platform with it's own authentication system.
  * LMS is built on top of OAuth for authentication
  * Kerberos is used for login on the Gradecraft website
  * We are using the existing kerberos_uid field on users to save LTI information
  * We at Gradecraft provide the Admin at U of M a URL, key, and secret, for Gradecraft to be available from within Canvas.
  * Gradecraft is accessible through a link on Canvas, which opens Gradecraft in a new tab
  * Student and Teachers can also login to Gradecraft directly, and interact with the app.
  * The GradeCraft login tab is used to authenticate users stored directly in the Gradecraft database
    * There is no interface to "sign up" as a Gradecraft user, these users are created by a Gradecraft Admin (/users/professors/new, /users/students/new)
    * Teachers can add student users to their classes
    * These Courses, Professors, Students etc. exist outside of and unlinked to any other LMS 
  * U of M Gradecraft users are authenticated, when they sign in using the "UM login link", on the back-end
    * A call is made from Canvas to user_sessions#lti_create with a key and secret
    * This should return an "valid user status" and launch Gradecraft as that user
    * These users are then saved to the GradeCraft database    
    * These students won't have a password saved to the database, they will always be authenticated through LTI
  * There is also an LTI provider model within the GradeCraft database
    * There are currently no LTI providers saved to the production database
    * There is no current functionality to connect to other Tool Providers 
    * This may be unfinished implementation of one of the LTI gems?
  
### LTI gems

There are two gems used for LTI: [ims-lti](https://github.com/instructure/ims-lti) and [omniauth-lti](https://github.com/xaviaracil/omniauth-lti). omniauth-lti handles authentication and relies on ims-lti for validating data.
 
### Tool Consumers, Tool Providers

#### Tool consumer provide the following information:

  * resource_link_id
  * resource_link_title
  * user_id
  * user_image
  * roles
  * lis_person_name_given
  * lis_person_name_family
  * lis_person_name_full
  * lis_person_contact_email_primary
  * context_id
  * context_title
  * context_label
  * oauth_consumer_key
  * oauth_signature
  * ...

[source: see LTIDataElements](http://developers.imsglobal.org/tutorials.html)

### Future Functionality

We hope to implement LTI 2, which will allow for greater information exchange between Gradecraft and tool consumers.


## LTI links

http://www.imsglobal.org/toolsinteroperability2.cfm
https://github.com/xaviaracil/omniauth-lti
https://github.com/instructure/ims-lti#returning-results-of-a-quizassignment
