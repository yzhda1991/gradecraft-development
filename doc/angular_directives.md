# Angular directives in Gradecraft

There are many ways to initiate an Angular app, the primary way we have settled on in GC is by using directives.
In order to "wire-up" a directive from the rails view, we need two things. We need to call our gradecraft app using `ng-app` on a parent element, and we need to add an element whose name will be picked up by our Angular directive.
Currently, we declare ng-app directly on the body element.

## Initiating in the View

Let's say we are going to create a directive called `myAwesomeGraph`, which needs two pieces of information, a student's id to collect the data from the endpoint, and a student's name in order to title the graph. In our rails view, we have something like this:

```
#class-analytics-graph
    %my-awesome-graph{ "student-name" => @student.name,
      "student-id" => @student.id}
```

Now when we define `myAwesomeGraph` in `/angular/directives/awesome/my_awesome_graph.coffee`, the graph will show up on this or any other view that adds this attribute.

**note:** Pay attention to the naming conventions here! In the haml: `my-awesome-graph`, and in the directive: `"myAwesomeGraph"` starting with a lower case letter. `student-id`, `student-name` in the view, `studentId`, `studentName` in the directive (see below). The filename is less critical, but we have standardized on snake_case.

## Anatomy of a Directive

There are several ways we can create a directive, with a controller, with a link, or simply returning a template. The most complicated is with a controller. We use this pattern when we need to use a service to get data from an api endpoint.

### Example Directive with a Controller

Here is an example directive with a controller, see below for an analysis of the different parts

```
gradecraft.directive 'myAwesomeGraph', ['$q', 'AwesomeService', ($q, AwesomeService) ->

    awesomeController = [()->
      vm = this
      services(vm.studentId).then(()->
        plotAwesomeGraph(vm.studentName, AwesomeService.awesomeData)
      )
    ]
    services = (studentId)->
      promises = [
        AwesomeService.getAssignmentAnalytics(studentId)
      ]
      return $q.all(promises)

    plotAwesomeGraph = (studentName, data)=>
      ...

    {
      bindToController: true,
      controller: awesomeController,
      controllerAs: 'vm',
      scope: {
         studentName: "@",
         studentId: "=",
        }
      templateUrl: 'awesome/awesome_graph.html'
    }
]
```

#### Declare the directive

First we define the new directive, and list the dependencies.

`gradecraft.directive 'myAwesomeGraph', ['$q', 'AwesomeService', ($q, AwesomeService) ->`

The strange syntax, with strings followed by values: `'$q', 'AwesomeService', ($q, AwesomeService)` assures us that the names of the variables won't get lost in minification.

We use `$q` to make sure that the AJAX data request has returned before we try to plot the graph.

We list all services that we will use to make calls to the api and where we house the returned data. This data can then be shared among directives that use this service.

#### View Model Namespace

We use `vm` (for "view-model", this is an Angular convention) to namespace variables in the controller and in the associated templates.

`vm = this`

`controllerAs: 'vm'`

#### Define service calls

We define a services function where we list the AJAX calls we need for this directive. This can be more setup that we might need (if we are only calling one service, for instance) but gives us a place where we could easily expand the directive's service calls later, if needed.

```
services = (studentId)->
  promises = [
    AwesomeService.getAssignmentAnalytics(studentId)
  ]
  return $q.all(promises)
```

We wrap the service calls in the promises array, these are iterated over by $q.all

#### Call our services

We make our service calls, and then once the data is returned, we can initiate other actions. Functions that aren't using Angular's two-way binding will only be called once, so things like graphs would be empty if we made the function call before the data was returned. Notice that the attributes from the view are available to us as vm.attribute

```
services(vm.studentId).then(()->
plotAwesomeGraph(vm.studentName, AwesomeService.awesomeData)
)
```

### Additional Functions

Now that we have our data, we can do things like plot graphs, turn off the "loading..." message, etc.

```
plotAwesomeGraph = (studentName, data)=>
...
```

### Return Object

A lot of the Angular configuration happens here:

```
{
  bindToController: true,
  controller: awesomeController,
  controllerAs: 'vm',
  scope: {
     studentName: "@",
     studentId: "=",
    }
  templateUrl: 'awesome/awesome_graph.html'
}
```

  * `bindToController` - this let's Angular know that we are using a controller in this directive
  * `controller` - here we give the name of the controller to use, as defined above
  * `controllerAs` -  this is the namespace for variables exposed to the template
  * `scope` - the attributes passed through the element
  * `templateUrl` - the name of the template to render (optional)

### Scope

These are the variables that are passed in as attributes from the view.

`"="` means that this variable should be converted to an object use this to get `true` instead of `"true"`, `100` instead of `"100"` etc.

`"@"` means use this variable as-is, this is good for strings.

There is a lot more information out there on these conventions than listed here, including `&`.
