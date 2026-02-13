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

if ($id <= 0 || $planning_id <= 0) {
  header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
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

$stmt = $db->prepare('DELETE FROM events WHERE id=?');
$stmt->execute([$id]);

$_SESSION['flash'] = ['success' => 'Événement supprimé.'];
header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week);
