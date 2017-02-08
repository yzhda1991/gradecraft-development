// Adapted from https://github.com/BrianGenisio/testdouble-jasmine

var testdoubleMatchers = {

  // For single use, call within spec:
  // jasmine.addMatchers(testdoubleMatchers.get(@testdouble));
  get: function(testdouble) {
    function verify(actual, options) {
      var options = options || {};

      if(!!actual && 'called' in actual) {
        delete actual.called;
        options = actual;
      }

      testdouble.verify(undefined, options);
    }

    var matchers = {
      toVerify: function(actual) {
        try {
          verify(actual);
          return true;
        } catch(e) {
          this.message = function() { return e.message; }
          return false;
        }
      }
    };

    if(jasmine.addMatchers) {
      // Jasmine 2.0
      matchers = {
        toVerify: function() {
          return {
            compare: function(expected, actual, options) {
              try {
                verify(actual, options);
                return { pass: true };
              } catch(e) {
                return {
                  pass: false,
                  message: e.message
                }
              }
            }
          }
        }
      };
    }
    return matchers;
  },

  // To make available within all specs, see current use in spec_helper.coffee
  use: function(testdouble) {
    beforeEach(function() {
      var matchers = testdoubleMatchers.get(testdouble);

      if(jasmine.addMatchers) {
        // Jasmine 2.0
        jasmine.addMatchers(matchers);
      } else {
        // Jasmine 1.0
        this.addMatchers(matchers);
      }
    });
  }
}
