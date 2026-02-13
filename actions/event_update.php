<?php
session_start();

require __DIR__ . '/../app/helpers/auth.php';

$config = require __DIR__ . '/../app/config/config.php';
$db = require __DIR__ . '/../app/config/db.php';

if (!current_user_id()) {
  header('Location: ' . $config['app']['base_url'] . '/?page=login');
  exit;
}

$id = (int)($_POST['id'] ?? 0);
$planning_id = (int)($_POST['planning_id'] ?? 0);
$week = trim($_POST['week'] ?? '');
$game_name = trim($_POST['game_name'] ?? '');
$game_image_url = trim($_POST['game_image_url'] ?? '');
$stream_title = trim($_POST['stream_title'] ?? '');
$start_time = trim($_POST['start_time'] ?? '');
$end_time = trim($_POST['end_time'] ?? '');

if ($id <= 0 || $planning_id <= 0 || $game_name === '' || $start_time === '' || $end_time === '') {
  $_SESSION['flash'] = ['error' => 'Champs manquants.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week);
  exit;
}

$stmt = $db->prepare('SELECT e.id,p.user_id FROM events e JOIN plannings p ON p.id=e.planning_id WHERE e.id=?');
$stmt->execute([$id]);
$row = $stmt->fetch();

if (!$row || (int)$row['user_id'] !== (int)current_user_id()) {
  $_SESSION['flash'] = ['error' => 'Action refusée.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
  exit;
}

if ($end_time <= $start_time) {
  $_SESSION['flash'] = ['error' => 'Heures invalides.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week);
  exit;
}

$stmt = $db->prepare('UPDATE events SET game_name=?, game_image_url=?, stream_title=?, start_time=?, end_time=? WHERE id=?');
$stmt->execute([
  $game_name,
  ($game_image_url !== '' ? $game_image_url : null),
  ($stream_title !== '' ? $stream_title : null),
  $start_time,
  $end_time,
  $id
]);

$_SESSION['flash'] = ['success' => 'Événement mis à jour.'];
header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week);
