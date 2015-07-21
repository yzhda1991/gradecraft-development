@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  GradeSchemeElementsService.getGradeSchemeElements().success (response)->
    #$scope.generateInputs(response.grade_scheme_elements)

  gse = @
  gse.onSubmit = () ->
    alert(JSON.stringify(gse.model), null, 2)
  #$scope.gse.model = {}
  # $scope.gse.fields = []

  gse.author = {
    # name: 'Joe Zhou',
    # url: 'https://plus.google.com/u/0/111062476999618400219/posts'
  }
  gse.exampleTitle = 'Repeating Section';
  # gse.env = {
  #   angularVersion: angular.version.full,
  #   formlyVersion: formlyVersion
  # }

  fieldOne = {
    className: 'row',
    fieldGroup: [
      {
        className: 'col-xs-4',
        type: 'input',
        key: 'investmentName',
        templateOptions: {
          label: 'Name of Investment:'
        }
      },
      {
        type: 'input',
        key: 'investmentDate',
        className: 'col-xs-4',
        templateOptions: {
          label: 'Date of Investment:',
          placeholder: 'dd/mm/yyyy such as 20/05/2015',
          dateFormat: 'DD, d  MM, yy'
        }
      },
      {
        type: 'input',
        key: 'stockIdentifier',
        className: 'col-xs-4',
        templateOptions: {
          label: 'Stock Identifier:'
        }
      }
    ]
  }

  fieldTwo = {
    "type": "radio",
    "key": "type",
    "templateOptions": {
      "options": [
        {
          "name": "Text Field",
          "value": "input"
        },
        {
          "name": "TextArea Field",
          "value": "textarea"
        },
        {
          "name": "Radio Buttons",
          "value": "radio"
        },
        {
          "name": "Checkbox",
          "value": "checkbox"
        }
      ],
      "label": "Field Type",
      "required": true
    }
  }

  fieldThree = {
    type: 'input',
    key: 'investmentValue',
    templateOptions: {
      label: 'Value:'
    },
    expressionProperties: {
      'templateOptions.disabled': '!model.stockIdentifier'
    }
  }

  fieldFour = {
    type: 'checkbox',
    model: 'formState',
    key: 'selfExecuting',
    templateOptions: {
      label: 'Are you executing this trade?'
    }
  }

  fieldFive = {
    hideExpression: '!formState.selfExecuting',
    fieldGroup: [
      {
        type: 'input',
        key: 'relationshipName',
        templateOptions: {
          label: 'Name:'
        }
      },
      {
        type: 'select',
        key: 'complianceApprover',
        templateOptions: {
          label: 'Compliance Approver:',
          options: [
            {
              name: 'approver 1',
              value:'some one 1'
            },
            {
              name: 'approver 2',
              value:'some one 2'
            }]
        }
      },
      {
        type: 'textarea',
        key: 'requestorComment',
        templateOptions: {
          label: 'Requestor Comment',
          rows: 4
        }
      }
    ]
  }

  init = () ->
    gse.fields = [
      {
        type: 'repeatSection',
        key: 'investments',
        templateOptions: {
          btnText:'Add another investment',
          fields: [
            fieldOne,
            fieldTwo,
            fieldThree,
            fieldFour,
            fieldFive
          ]
        }
      }
    ]
    gse.model = {
      investments: [
        {
          investmentName:'abc',
          investmentDate:(new Date()).toDateString(),
          stockIdentifier:'',
          investmentValue:'',
          relationshipName:'',
          complianceApprover:'',
          requestorComment:''
        },
        {
          investmentName:'haf',
          investmentDate:(new Date()).toDateString(),
          stockIdentifier:'',
          investmentValue:'',
          relationshipName:'',
          complianceApprover:'',
          requestorComment:''
        }
      ]
    }
    return

  init()
  gse.originalFields = angular.copy(gse.fields);

  # $scope.generateInput = (element) ->
  #   tmp = {}
  #   tmp.type = 'input'
  #   tmp.templateOptions = {}
  #   tmp.key = 'parentType'
  #   tmp.templateOptions.label = element.letter
  #   tmp

  # $scope.generateInputs = (elements) ->
  #   fields = []
  #   angular.forEach elements, (element, index)->
  #     fields.push $scope.generateInput(element)
  #   $scope.gse.fields = fields
  return
]









###############################################
#############################################
###############################

# /* global angular */
# (function() {

#   'use strict';

#   var app = angular.module('formlyExample', ['formly', 'formlyBootstrap'], function config(formlyConfigProvider) {
#     formlyConfigProvider.setType({
#       name: 'repeatSection',
#       templateUrl: 'repeatSection.html',
#       controller: function($scope) {
#         $scope.formOptions = {formState: $scope.formState};
#         $scope.addNew = addNew;

#         $scope.copyFields = copyFields;

#         function copyFields(fields) {
#           return angular.copy(fields);
#         }

#         function addNew() {
#           $scope.model[$scope.options.key] = $scope.model[$scope.options.key] || [];
#           var repeatsection = $scope.model[$scope.options.key];
#           var lastSection = repeatsection[repeatsection.length - 1];
#           var newsection = {};
#           if (lastSection) {
#             newsection = angular.copy(lastSection);
#           }

#           repeatsection.push(newsection);
#         }
#       }
#     });
#   });


  # app.controller('MainCtrl', function MainCtrl(formlyVersion) {
  #   var vm = this;
  #   // funcation assignment
  #   vm.onSubmit = onSubmit;

  #   // variable assignment
  #   vm.author = { // optionally fill in your info below :-)
  #     name: 'Joe Zhou',
  #     url: 'https://plus.google.com/u/0/111062476999618400219/posts' // a link to your twitter/github/blog/whatever
  #   };
  #   vm.exampleTitle = 'Repeating Section'; // add this
  #   vm.env = {
  #     angularVersion: angular.version.full,
  #     formlyVersion: formlyVersion
  #   };

  #   init();

  #   vm.originalFields = angular.copy(vm.fields);

  #   // function definition
  #   function onSubmit() {
  #     alert(JSON.stringify(vm.model), null, 2);
  #   }


  #   function init() {
  #     vm.model = {
  #       investments: [
  #         {
  #           investmentName:'abc',
  #           investmentDate:(new Date()).toDateString(),
  #           stockIdentifier:'',
  #           investmentValue:'',
  #           relationshipName:'',
  #           complianceApprover:'',
  #           requestorComment:''
  #         },
  #         {
  #           investmentName:'haf',
  #           investmentDate:(new Date()).toDateString(),
  #           stockIdentifier:'',
  #           investmentValue:'',
  #           relationshipName:'',
  #           complianceApprover:'',
  #           requestorComment:''
  #         }
  #       ]
  #     };

  #     vm.fields = [
  #       {
  #         type: 'repeatSection',
  #         key: 'investments',
  #         templateOptions: {
  #           btnText:'Add another investment',
  #           fields: [
  #             {
  #               className: 'row',
  #               fieldGroup: [
  #                 {
  #                   className: 'col-xs-4',
  #                   type: 'input',
  #                   key: 'investmentName',
  #                   templateOptions: {
  #                     label: 'Name of Investment:'
  #                   }
  #                 },
  #                 {
  #                   type: 'input',
  #                   key: 'investmentDate',
  #                   className: 'col-xs-4',
  #                   templateOptions: {
  #                     label: 'Date of Investment:',
  #                     placeholder: 'dd/mm/yyyy such as 20/05/2015',
  #                     dateFormat: 'DD, d  MM, yy'
  #                   }
  #                 },
  #                 {
  #                   type: 'input',
  #                   key: 'stockIdentifier',
  #                   className: 'col-xs-4',
  #                   templateOptions: {
  #                     label: 'Stock Identifier:'
  #                   }
  #                 }
  #               ]
  #             },
  #             {
  #               "type": "radio",
  #               "key": "type",
  #               "templateOptions": {
  #                 "options": [
  #                   {
  #                     "name": "Text Field",
  #                     "value": "input"
  #                   },
  #                   {
  #                     "name": "TextArea Field",
  #                     "value": "textarea"
  #                   },
  #                   {
  #                     "name": "Radio Buttons",
  #                     "value": "radio"
  #                   },
  #                   {
  #                     "name": "Checkbox",
  #                     "value": "checkbox"
  #                   }
  #                 ],
  #                 "label": "Field Type",
  #                 "required": true
  #               }
  #             },
  #             {
  #               type: 'input',
  #               key: 'investmentValue',
  #               templateOptions: {
  #                 label: 'Value:'
  #               },
  #               expressionProperties: {
  #                 'templateOptions.disabled': '!model.stockIdentifier'
  #               }
  #             },
  #             {
  #               type: 'checkbox',
  #               model: 'formState',
  #               key: 'selfExecuting',
  #               templateOptions: {
  #                 label: 'Are you executing this trade?'
  #               }
  #             },
  #             {
  #               hideExpression: '!formState.selfExecuting',
  #               fieldGroup: [
  #                 {
  #                   type: 'input',
  #                   key: 'relationshipName',
  #                   templateOptions: {
  #                     label: 'Name:'
  #                   }
  #                 },
  #                 {
  #                   type: 'select',
  #                   key: 'complianceApprover',
  #                   templateOptions:
  #                   {
  #                     label: 'Compliance Approver:',
  #                     options: [
  #                       {
  #                         name: 'approver 1',
  #                         value:'some one 1'
  #                       },
  #                       {
  #                         name: 'approver 2',
  #                         value:'some one 2'
  #                       }]
  #                   }
  #                 },
  #                 {
  #                   type: 'textarea',
  #                   key: 'requestorComment',
  #                   templateOptions:
  #                   {
  #                     label: 'Requestor Comment',
  #                     rows: 4
  #                   }
  #                 }
  #               ]
  #             }
  #           ]
  #         }

  #       }
  #     ];
  #   }
  # });
