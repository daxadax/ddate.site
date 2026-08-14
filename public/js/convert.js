(function () {
  var config = window.DDATE;
  if (!config) return;

  var form = document.getElementById('chao-form');
  if (!form) return;

  var dayInput = document.getElementById('day');
  var dayNumber = document.getElementById('day-number');
  var weekdayName = document.getElementById('weekday-name');
  var stTibs = document.getElementById('st_tibs');
  var portalArrow = document.getElementById('portal-arrow');
  var convertGlyph = document.getElementById('convert-glyph');
  var subtitle = document.getElementById('converter-subtitle');
  var currentDirection = config.direction;

  var waitingPodge = '<div class="revelation revelation--waiting">' +
    '<span class="revelation-title">Awaiting Revelation</span>' +
    '<span class="revelation-body">Submit a Greyface date</br>to toss the golden apple</span>' +
    '<span class="revelation-footer">Temple of Eris · Department of Unreason</span>' +
    '</div>';

  var waitingHodge = '<div class="stamp stamp--waiting">' +
    '<span class="stamp-title">Awaiting Transmission</span>' +
    '<span class="stamp-body">Select a Discordian date and sate your hunger for order</span>' +
    '<span class="stamp-footer">Curse of Greyface Compliance Desk</span>' +
    '</div>';

  function monthIndex(name) {
    return config.months.indexOf(name);
  }

  function selectedMonth() {
    var checked = form.querySelector('input[name="month"]:checked');
    return checked ? checked.value : config.months[0];
  }

  function selectedDirection() {
    var checked = form.querySelector('input[name="direction"]:checked');
    return checked ? checked.value : 'to_hodge';
  }

  function weekdayFor(month, day, tibs) {
    if (tibs) return "St. Tib's Day";
    var yday = monthIndex(month) * 73 + Number(day);
    return config.weekdays[yday % 5];
  }

  function syncDayReadout() {
    if (!dayInput || !dayNumber || !weekdayName || !stTibs) return;

    var month = selectedMonth();
    var day = dayInput.value;
    var tibs = stTibs.checked;

    dayNumber.textContent = tibs ? '—' : day;
    weekdayName.textContent = weekdayFor(month, day, tibs);
    dayInput.disabled = tibs;
  }

  function clearResults() {
    var podgeOutput = form.querySelector('.podge-output');
    var hodgeOutput = form.querySelector('.hodge-output');
    var podgeRealm = form.querySelector('.realm-podge');
    var hodgeRealm = form.querySelector('.realm-hodge');

    if (podgeOutput) podgeOutput.innerHTML = waitingPodge;
    if (hodgeOutput) hodgeOutput.innerHTML = waitingHodge;
    if (podgeRealm) podgeRealm.classList.remove('realm-podge--revealed');
    if (hodgeRealm) hodgeRealm.classList.remove('realm-hodge--revealed');
  }

  function syncDirection() {
    var direction = selectedDirection();
    form.classList.remove('chao-form--to_hodge', 'chao-form--to_podge');
    form.classList.add('chao-form--' + direction);

    if (direction !== currentDirection) {
      clearResults();
      currentDirection = direction;
    }

    if (portalArrow) {
      portalArrow.textContent = direction === 'to_podge' ? '⇠' : '⇢';
    }

    if (convertGlyph) {
      convertGlyph.innerHTML = '<span class="convert-glyph-wobble">' +
        (direction === 'to_podge' ? '🌭' : '🍎') + '</span>';
    }

    if (subtitle) {
      subtitle.textContent = direction === 'to_podge'
        ? 'Greyface to Erisian'
        : 'Erisian to Greyface';
    }

    if (direction === 'to_hodge') {
      syncDayReadout();
    }
  }

  form.addEventListener('change', function (event) {
    if (event.target.name === 'direction') {
      syncDirection();
      return;
    }
    syncDayReadout();
  });

  if (dayInput) {
    dayInput.addEventListener('input', syncDayReadout);
  }

  form.addEventListener('submit', function () {
    form.classList.add('is-consulting');
  });

  syncDirection();
})();
