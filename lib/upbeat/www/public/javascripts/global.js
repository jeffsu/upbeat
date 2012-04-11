
function percentage(count, total) {
  if (total > 0) {
    return (Math.round(count/total*10000) / 100) + '%';
  } else {
    return '0%';
  }
}
