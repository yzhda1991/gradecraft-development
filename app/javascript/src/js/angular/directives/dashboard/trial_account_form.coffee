gradecraft.directive "trialAccountForm", [() ->
  {
    scope:
      isTrialAccount: "="
      newExternalCoursesPath: "@"
    controllerAs: "trialAccountFormCtrl"
    templateUrl: "dashboard/trial_account_form.html"
  }
]
