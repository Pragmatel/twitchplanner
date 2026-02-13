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
if ($id <= 0) {
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

$stmt = $db->prepare('DELETE FROM plannings WHERE id=?');
$stmt->execute([$id]);

$_SESSION['flash'] = ['success' => 'Planning supprimé.'];
header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
