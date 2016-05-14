// Leaderboard Page
$('table.dynatable').dynatable({
  features: {
      paginate: false,
      search: false,
      recordCount: false
    },
    readers: {
      score: numericScore,
      maxPoints: numericScore,
      min: numericScore,
      median: numericScore,
      max: numericScore,
      ave: numericScore,
      points: numericScore,
      rank: numericScore,
      openDate: convertedDate,
      dueDate: convertedDate,
      blog: alphaNumeric
    }
});

function alphaNumeric(cell, record) {
  record['alphaNumeric'] = cell.textContent.replace(/\d+/g,function(match){return pad(match,4)});
  return cell.innerHTML;
}

function numericScore(cell, record) {
  record['numericScore'] = parseInt(cell.textContent.replace(/[^0-9]/g, ""));
  return cell.innerHTML;
}

function randomScore(cell, record) {
  record['numericScore'] = Math.random();
  cell.textContent += " " + record['numericScore'];
  return cell.innerHTML;
}

function convertedDate(cell, record) {
  var parsedDate = moment(cell.textContent, "MMMM D, YYYY").valueOf();
  record['convertedDate'] = parsedDate;
  return cell.innerHTML;
}

function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}
