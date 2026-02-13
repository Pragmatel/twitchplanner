<?php
session_start();

require __DIR__ . '/../app/helpers/auth.php';
require __DIR__ . '/../app/helpers/weeks.php';

$configPath = __DIR__ . '/../app/config/config.php';
if (!file_exists($configPath)) {
  http_response_code(500);
  echo '<div style="font-family:Arial;padding:24px"><h2>Config manquante</h2><p>Copie app/config/config.example.php vers app/config/config.php</p></div>';
  exit;
}

$config = require $configPath;
$flash = $_SESSION['flash'] ?? [];
unset($_SESSION['flash']);

$page = $_GET['page'] ?? 'home';
$db = require __DIR__ . '/../app/config/db.php';

if ($page === 'home') { require __DIR__ . '/../app/views/home.php'; exit; }

if ($page === 'register') {
  if (current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; }
  require __DIR__ . '/../app/views/auth_register.php'; exit;
}

if ($page === 'login') {
  if (current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; }
  require __DIR__ . '/../app/views/auth_login.php'; exit;
}

if ($page === 'profile') {
  require_auth($config['app']['base_url']);
  $stmt = $db->prepare('SELECT id,email,twitch_url,logo_path FROM users WHERE id=?');
  $stmt->execute([current_user_id()]);
  $user = $stmt->fetch();
  require __DIR__ . '/../app/views/profile.php'; exit;
}

if ($page === 'plannings') {
  require_auth($config['app']['base_url']);
  $today = (new DateTime())->format('Y-m-d');
  $defaultWeekStart = week_start_from_date($today);
  $stmt = $db->prepare('SELECT id,title,week_start FROM plannings WHERE user_id=? ORDER BY created_at DESC');
  $stmt->execute([current_user_id()]);
  $plannings = $stmt->fetchAll();
  require __DIR__ . '/../app/views/plannings_list.php'; exit;
}

if ($page === 'planning') {
  require_auth($config['app']['base_url']);
  $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
  if ($id <= 0) { header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; }

  $stmt = $db->prepare('SELECT id,user_id,title,week_start FROM plannings WHERE id=?');
  $stmt->execute([$id]);
  $planning = $stmt->fetch();

  if (!$planning || (int)$planning['user_id'] !== (int)current_user_id()) {
    $_SESSION['flash'] = ['error' => 'Accès refusé.'];
    header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
    exit;
  }

  $weekStart = $_GET['week'] ?? $planning['week_start'];
  $weekStart = week_start_from_date($weekStart);
  $days = week_range($weekStart);
  $prevWeek = add_days($weekStart, -7);
  $nextWeek = add_days($weekStart, 7);

  $stmt = $db->prepare('SELECT id,planning_id,game_name,game_image_url,stream_title,day_of_week,start_time,end_time FROM events WHERE planning_id=? ORDER BY day_of_week ASC, start_time ASC');
  $stmt->execute([$planning['id']]);
  $events = $stmt->fetchAll();

  $eventsByDay = [];
  foreach ($events as $ev) {
    $dow = (int)$ev['day_of_week'];
    if (!isset($eventsByDay[$dow])) $eventsByDay[$dow] = [];
    $eventsByDay[$dow][] = $ev;
  }

  require __DIR__ . '/../app/views/planning_edit.php'; exit;
}

http_response_code(404);
echo 'Page introuvable';
