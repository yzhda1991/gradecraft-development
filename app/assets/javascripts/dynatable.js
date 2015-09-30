// Leaderboard Page
$('table.dynatable').dynatable({
  readers: {
    rank: function(el, record) {
      return Number(el.innerHTML) || 0;
    }
    ,
    score: function(el, record) {
      if($.trim(el.innerHTML) == '') {
        return el.innerHTML;
      } else {
        return Number(el.innerHTML.replace(/,/g,""));
      }
    }
  },
  writers: {
    score: function(record) {
      return record['score'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  }
});

$('table.nopage_dynatable').dynatable({
  features: {
        paginate: false,
        sort: true
      },
  readers: {
    rank: function(el, record) {
      return Number(el.innerHTML) || 0;
    },
    score: function(el, record) {
      if($.trim(el.innerHTML) == '') {
        return el.innerHTML;
      } else {
        return Number(el.innerHTML.replace(/,/g,""));
      }
    },
    totalScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    badgeScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    rawScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    multipliedScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    meanScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    challengeScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    students: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    badges: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    min: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    max: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    median: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    ave: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    aveEarned: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    submissions: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    grades: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    }
  },
  writers: {
    score: function(record) {
      return record['score'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    min: function(record) {
      return record['min'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    max: function(record) {
      return record['max'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    median: function(record) {
      return record['median'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    ave: function(record) {
      return record['ave'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    aveEarned: function(record) {
      return record['aveEarned'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    median: function(record) {
      return record['median'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    submissions: function(record) {
      return record['submissions'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    grades: function(record) {
      return record['grades'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  }
});

$('table.nosearch_dynatable').dynatable({
  features: {
        search: false,
        sort: true
      },
  readers: {
    rank: function(el, record) {
      return Number(el.innerHTML) || 0;
    },
    score: function(el, record) {
      if($.trim(el.innerHTML) == '') {
        return el.innerHTML;
      } else {
        return Number(el.innerHTML.replace(/,/g,""));
      }
    }
  },
  writers: {
    score: function(record) {
      return record['score'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  }
});

$('table.nopage_orsearch_dynatable').dynatable({
  features: {
    search: false,
    paginate: false,
    sort: true
  }
});

$('table.nofeatures_default_last_name_dynatable').dynatable({
  features: {
    paginate: false,
    search: false,
    recordCount: false,
    sort: true
  },
  dataset: {
    sorts: { 'lastName': 1 }
  },
  readers: {
    dueDate: function(el, record) {
      record.parsedDate = Date.parse(el.innerHTML);
      return el.innerHTML;
    },
    points: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,""));
    },
    maxValue: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,""));
    },
    totalBadgeScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,""));
    },
    badgeCount: function(el, record) {
      return Number(el.innerHTML.replace()) || 0;
    },
    score: function(el, record) {
      if($.trim(el.innerHTML) == '') {
        return el.innerHTML;
      } else {
        return Number(el.innerHTML.replace(/,/g,""));
      }
    },
    rawScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,""));
    },
    multipliedScore: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    }
  },
  writers: {
    score: function(record) {
      return record['score'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    totalBadgeScore: function(record) {
      return record['totalBadgeScore'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  }
});

$('table.nofeatures_default_name_dynatable').dynatable({

  features: {
        paginate: false,
        search: false,
        recordCount: false,
        sort: true
      },
  dataset: {
      sorts: { 'name': 1 }
  },
  readers: {
      dueDate: function(el, record) {
        record.parsedDate = Date.parse(el.innerHTML);
        return el.innerHTML;
      },
      points: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      maxPoints: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      }
    }
});

$('table.nofeatures_default_score_dynatable').dynatable({
  features: {
        paginate: false,
        search: false,
        recordCount: false,
        sort: true
      },
  dataset: {
      sorts: { 'score': -1 }
  },
  readers: {
      score: function(el, record) {
        if($.trim(el.innerHTML) == '') {
          return el.innerHTML;
        } else {
          return Number(el.innerHTML.replace(/,/g,""));
        }
      },
      dueDate: function(el, record) {
        record.parsedDate = Date.parse(el.innerHTML);
        return el.innerHTML;
      },
      points: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      maxValue: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      rank: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      meanStudentScore: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      challengeScore: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      badges: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      students: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      pointsEarned: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      }
    },
    writers: {
      score: function(record) {
        return record['score'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
      },
      pointsEarned: function(record) {
        return record['pointsEarned'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
      }
    }
});

$('table.nofeatures_default_desc_score_dynatable').dynatable({

  features: {
        paginate: false,
        search: false,
        recordCount: false,
        sort: true
      },
  dataset: {
      sorts: { 'score': -1 }
  }
});

function assignmentSort(a, b, attr, direction) {
  var num = parseInt($(a.assignment).text().split('').pop());
  var a = Array.prototype.alphanumSort($(a.assignment).text())
  debugger;
}

$('table.default_assignments_dynatable').bind('dynatable:init', function(e, dynatable) {
  dynatable.sorts.functions["alphaNumeric"] = assignmentSort;
}).dynatable({
  features: {
    paginate: false,
    search: false,
    recordCount: false,
    sort: true
  },
  dataset: {
    sortTypes: {
      assignment: 'alphaNumeric'
    }
  }
});

// function naturalSorter(as, bs){
//     var a, b, a1, b1, i= 0, n, L,
//     rx=/(\.\d+)|(\d+(\.\d+)?)|([^\d.]+)|(\.\D+)|(\.$)/g;
//     if(as=== bs) return 0;
//     a= as.toLowerCase().match(rx);
//     b= bs.toLowerCase().match(rx);
//     L= a.length;
//     while(i<L){
//         if(!b[i]) return 1;
//         a1= a[i],
//         b1= b[i++];
//         if(a1!== b1){
//             n= a1-b1;
//             if(!isNaN(n)) return n;
//             return a1>b1? 1:-1;
//         }
//     }
//     return b[i]? -1:0;
// }

// $(document).ready(function () {
//     var selectModel = [];

//     $('select.text12 option').each(function () {
//         var $this = $(this);
//         selectModel.push({
//             value: $this.val(),
//             text: $this.text()
//         });
//     });

//     selectModel.sort(function (a, b) {
//         return naturalSorter(a.text, b.text);
//     });

//     var tempHtml = '';

//     for (var i = 0, ii = selectModel.length; i < ii; i++) {
//         tempHtml += '<option value="' + selectModel[i].value + '">' + selectModel[i].text + '</option>';
//     }

//     $('select.text12').html(tempHtml);
// });

$('table.nofeatures_dynatable').dynatable({

  features: {
        paginate: false,
        search: false,
        recordCount: false,
        sort: true
      },
  readers: {
      dueDate: function(el, record) {
        record.parsedDate = Date.parse(el.innerHTML);
        return el.innerHTML;
      },
      points: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      maxValue: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      lowRange: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      highRange: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      },
      points: function(el, record) {
        return Number(el.innerHTML.replace(/,/g,"")) || 0;
      }
    },
  writers: {
    points: function(record) {
      return record['points'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    lowRange: function(record) {
      return record['lowRange'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    highRange: function(record) {
      return record['highRange'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  }
});


$('table.nofeatures_default_due_date_dynatable').dynatable({
  features: {
    paginate: false,
    search: false,
    recordCount: false,
    sort: true
  },
  dataset: {
    sorts: { 'dueDate': 1 }
  },
  readers: {
    dueDate: function(el, record) {
      record.parsedDate = Date.parse(el.innerHTML);
      return el.innerHTML;
    },
    points: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    maxPoints: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    },
    pointsEarned: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,"")) || 0;
    }
  },
  writers: {
    maxPoints: function(record) {
      return record['maxPoints'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
    pointsEarned: function(record) {
      return record['pointsEarned'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  }
});

$('table.nofeatures_default_rank_dynatable').dynatable({
  features: {
    paginate: false,
    search: false,
    recordCount: false,
    sort: true
  },
  dataset: {
    sorts: { 'rank': 1 }
  },
  readers: {
    rank: function(el, record) {
      return Number(el.innerHTML) || 0;
    },
    score: function(el, record) {
      if($.trim(el.innerHTML) == '') {
        return el.innerHTML;
      } else {
        return Number(el.innerHTML.replace(/,/g,""));
      }
    },
    badgeCount: function(el, record) {
      return Number(el.innerHTML.replace(/,/g,""));
    }
  },
  writers: {
    score: function(record) {
      return record['score'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  }
});

$('table.paginate_default_last_name_dynatable').dynatable({

 features: {
        sort: true
      },
  dataset: {
      sorts: { 'lastName': 1 },
      perPageDefault: 25,
      perPageOptions: [25, 50, 100]
  },
  readers: {
      points: function(el, record) {
        return Number(el.innerHTML.replace(",","")) || 0;
      }
    }
});
