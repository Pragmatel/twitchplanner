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

$title = trim($_POST['title'] ?? '');
$week_start = trim($_POST['week_start'] ?? '');

if ($title === '' || $week_start === '') {
  $_SESSION['flash'] = ['error' => 'Champs manquants.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
  exit;
}

$week_start = week_start_from_date($week_start);

$stmt = $db->prepare('INSERT INTO plannings (user_id,title,week_start) VALUES (?,?,?)');
$stmt->execute([current_user_id(), $title, $week_start]);

$_SESSION['flash'] = ['success' => 'Planning créé.'];
header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
