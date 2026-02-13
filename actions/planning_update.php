<?php
session_start();

require __DIR__ . '/../app/helpers/auth.php';
require __DIR__ . '/../app/helpers/weeks.php';

$config = require __DIR__ . '/../app/config/config.php';
$db = require __DIR__ . '/../app/config/db.php';

if (!current_user_id()) {
  header('Location: ' . $config['app']['base_url'] . '/?page=login');
  exit;
}

$id = (int)($_POST['id'] ?? 0);
$title = trim($_POST['title'] ?? '');
$week_start = trim($_POST['week_start'] ?? '');

if ($id <= 0 || $title === '' || $week_start === '') {
  $_SESSION['flash'] = ['error' => 'Champs manquants.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
  exit;
}

$stmt = $db->prepare('SELECT id,user_id FROM plannings WHERE id=?');
$stmt->execute([$id]);
$p = $stmt->fetch();

if (!$p || (int)$p['user_id'] !== (int)current_user_id()) {
  $_SESSION['flash'] = ['error' => 'Action refusée.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
  exit;
}

$week_start = week_start_from_date($week_start);

$stmt = $db->prepare('UPDATE plannings SET title=?, week_start=? WHERE id=?');
$stmt->execute([$title, $week_start, $id]);

$_SESSION['flash'] = ['success' => 'Planning mis à jour.'];
header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $id . '&week=' . $week_start);
