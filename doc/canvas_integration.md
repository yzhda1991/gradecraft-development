# Canvas Integration

### Features
  * Import grades
  * Import/update assignments to and from Gradecraft
  * Import users
  * Dynamic providers for Institutions/Courses

### Omniauth Workflow
If the user has not previously authenticated with Canvas via OAuth, they will be redirected to the Canvas login page. Once access is granted by the user, their token information will be stored on the `UserAuthorization` model.

If no Canvas course has been linked yet to Gradecraft, the user will be prompted to do so prior to performing any sort of import operation. The information relating to this process will then be stored and referred to on the `LinkedCourse` model.

Token validity and refresh behavior is handled by the `OAuthProvider` and `ExternalAuthorization` concerns. The `OAuthProvider` class expects a provider in order to require authorization. In order to properly redirect the user back to the intended location after authenticating with Canvas, the redirect_path must be set wherever authorization is explicitly required.

```
before_action do |controller|
  controller.redirect_path {intended_path})
end
```

To ensure that the provider configuration is dynamically configured prior to the request, the following controller filter should be added:

```
before_action :link_canvas_credentials, if: Proc.new { |c| c.params[:importer_provider_id] == "canvas" }
```

This will ensure that the OAuth keys are loaded for the current course based on the linked provider of the institution it belongs to.

The Omniauth setup phase happens in the `CanvasSessionController`. See [the Omniauth docs regarding this](https://github.com/omniauth/omniauth/wiki/Dynamic-Providers) or [the Omniauth Canvas docs](https://github.com/atomicjolt/omniauth-canvas#setup) for additional details.

### ActiveLMS

For single site usage, the `ActiveLMS` initializer in `config/initializers/active_lms.rb` will pull OAuth app credentials from ENV variables. Set the following to their appropriate values:

* CANVAS\_CLIENT_ID
* CANVAS\_CLIENT_SECRET
* CANVAS\_BASE_URL

For multiple or app configured sites, do not set the required credentials in the ENV file. Instead store these credentials on a linked `Provider`, belonging either to a `Course` or an `Institution`.

`ActiveLMS::Syllabus` is intended to be a wrapper for common operations that we might want to perform with external LMSs. It is structured such that is agnostic to the provider, leaving the implementation details to the provider's own class definition. See `ActiveLMS::CanvasSyllabus` as an example.

`Canvas::API` takes care of the request and response handling with the Canvas API. Note that `#get_data` can optionally take a parameter that specifies whether additional pages should be automatically fetched.

### Import Grades

By default, grades are loaded via AJAX for preview and selection in batches of 25. Each batch request makes a call to `API::Grades::ImportersController#show`.

#### Notes:
* Canvas allows for many comments on a grade. If such a grade is imported to Gradecraft, each comment will be concatenated together to form a string that resembles the following pattern:

`Comment 1: {comment_1}; Comment 2: {comment_2}...`

### Import Assignments

Assignments from Canvas are imported to Gradecraft. An assignment type must be specified, or the import will fail.

Afterwards, the assignment can be synced either to or from Canvas in order to update changes.
  
### Import Users

Users for the linked course can be imported to the current course with their translated role. The following chart outlines the translation between a role in Canvas with a role in Gradecraft:

```
studentenrollment -> student
teacherenrollment -> professor
taenrollment, designerenrollment -> gsi
anything else -> observer
```

Since Canvas allows for the possibility of having multiple roles in a course, Gradecraft filters out only the active roles returned by the API and selects only the one of highest precedence to create for the current course.

`teacherenrollment > designerenrollment > taenrollment > studentenrollment > observerenrollment`