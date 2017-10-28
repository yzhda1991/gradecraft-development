// Leaderboard Page
$('table.dynatable').bind('dynatable:init', function(e, dynatable) {
      dynatable.sorts.functions["numeric"] = numeric;
      dynatable.sorts.functions["alphanum"] = alphanum;
    }).dynatable({
  features: {
      paginate: false,
      search: true,
      recordCount: false
    },
    dataset: {
      sortTypes: {
        score: 'numeric',
        rank: 'numeric',
        grades: 'numeric',
        submissions: 'numeric',
        predicted: 'numeric',
        min: 'numeric',
        max: 'numeric',
        median: 'numeric',
        maxPoints: 'numeric',
        aveTheAverageOfAllGradesIncludingThoseWhoEarnedZero: 'numeric',
        avgEarnedTheAverageOfAllScoresAboveZero: 'numeric',
        blog: 'alphanum',
        scoreWithWeights: 'numeric',
        finalScore: 'numeric',
        predictedScore: 'numeric',
        id: 'numeric',
        lastLogin: 'numeric',
        calendarDate: 'numeric',
        openDateSort: 'numeric',
        closeDateSort: 'numeric'
      }
    }
});

function numeric(a, b, attr, direction) {
  var aa = a[attr].replace(/[^0-9]/g, "");
  var bb = b[attr].replace(/[^0-9]/g, "");
  return aa === bb ? 0 : (direction > 0 ? aa - bb : bb - aa);
}

function alphanum(a, b, attr, direction) {
  var aa = a[attr].replace(/\d+/g, function(match) {
    return pad(match, 4)
  });
  var bb = b[attr].replace(/\d+/g, function(match) {
    return pad(match, 4)
  });
  return aa === bb ? 0 : (direction > 0 ? aa > bb : !(aa > bb));
}

function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

$('table.paginated_dynatable').bind('dynatable:init', function(e, dynatable) {
      dynatable.sorts.functions["numeric"] = numeric;
      dynatable.sorts.functions["alphanum"] = alphanum;
    }).dynatable({
  features: {
      paginate: true,
      search: true,
      recordCount: true
    },
    dataset: {
      sortTypes: {
        score: 'numeric',
        rank: 'numeric',
        date: 'numeric',
        blog: 'alphanum'
      }
    }
});

$('table.unfancy_dynatable').bind('dynatable:init', function(e, dynatable) {
      dynatable.sorts.functions["numeric"] = numeric;
      dynatable.sorts.functions["alphanum"] = alphanum;
    }).dynatable({
  features: {
      paginate: false,
      search: false,
      recordCount: false
    },
    dataset: {
      sortTypes: {
        score: 'numeric',
        rank: 'numeric',
        date: 'numeric',
        blog: 'alphanum'
      }
    }
});
