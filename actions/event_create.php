<?php
session_start();

require __DIR__ . '/../app/helpers/auth.php';

$config = require __DIR__ . '/../app/config/config.php';
$db = require __DIR__ . '/../app/config/db.php';

if (!current_user_id()) {
  header('Location: ' . $config['app']['base_url'] . '/?page=login');
  exit;
}

$planning_id = (int)($_POST['planning_id'] ?? 0);
$day_of_week = (int)($_POST['day_of_week'] ?? -1);
$week = trim($_POST['week'] ?? '');
$game_name = trim($_POST['game_name'] ?? '');
$game_image_url = trim($_POST['game_image_url'] ?? '');
$stream_title = trim($_POST['stream_title'] ?? '');
$start_time = trim($_POST['start_time'] ?? '');
$end_time = trim($_POST['end_time'] ?? '');

if ($planning_id <= 0 || $day_of_week < 0 || $day_of_week > 6 || $game_name === '' || $start_time === '' || $end_time === '') {
  $_SESSION['flash'] = ['error' => 'Champs manquants.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week);
  exit;
}

$stmt = $db->prepare('SELECT id,user_id FROM plannings WHERE id=?');
$stmt->execute([$planning_id]);
$p = $stmt->fetch();

if (!$p || (int)$p['user_id'] !== (int)current_user_id()) {
  $_SESSION['flash'] = ['error' => 'Action refusée.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
  exit;
}

if ($end_time <= $start_time) {
  $_SESSION['flash'] = ['error' => 'Heures invalides.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week);
  exit;
}

$stmt = $db->prepare('INSERT INTO events (planning_id,game_name,game_image_url,stream_title,day_of_week,start_time,end_time) VALUES (?,?,?,?,?,?,?)');
$stmt->execute([
  $planning_id,
  $game_name,
  ($game_image_url !== '' ? $game_image_url : null),
  ($stream_title !== '' ? $stream_title : null),
  $day_of_week,
  $start_time,
  $end_time
]);

$_SESSION['flash'] = ['success' => 'Événement ajouté.'];
header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week);
