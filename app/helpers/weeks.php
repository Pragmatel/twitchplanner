<?php
function week_start_from_date($dateStr) {
  $dt = new DateTime($dateStr);
  $day = (int)$dt->format('N');
  $dt->modify('-' . ($day - 1) . ' days');
  return $dt->format('Y-m-d');
}

function week_range($weekStart) {
  $start = new DateTime($weekStart);
  $days = [];
  for ($i = 0; $i < 7; $i++) {
    $d = clone $start;
    $d->modify('+' . $i . ' days');
    $days[] = [
      'date' => $d->format('Y-m-d'),
      'label' => $d->format('D d/m'),
      'dow' => $i
    ];
  }
  return $days;
}

function add_days($dateStr, $days) {
  $dt = new DateTime($dateStr);
  $dt->modify(($days >= 0 ? '+' : '') . $days . ' days');
  return $dt->format('Y-m-d');
}
