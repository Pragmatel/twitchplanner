<?php
session_start();

require __DIR__ . '/../app/helpers/auth.php';

$config = require __DIR__ . '/../app/config/config.php';
$db = require __DIR__ . '/../app/config/db.php';

if (!current_user_id()) {
  header('Location: ' . $config['app']['base_url'] . '/?page=login');
  exit;
}

$email = trim($_POST['email'] ?? '');
$password = (string)($_POST['password'] ?? '');
$twitch_url = trim($_POST['twitch_url'] ?? '');
$logo_path = null;

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
  $_SESSION['flash'] = ['error' => 'Email invalide.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=profile');
  exit;
}

$stmt = $db->prepare('SELECT id FROM users WHERE email=? AND id!=?');
$stmt->execute([$email, current_user_id()]);
if ($stmt->fetch()) {
  $_SESSION['flash'] = ['error' => 'Cet email est déjà utilisé.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=profile');
  exit;
}

if (!empty($_FILES['logo']['name'])) {
  $file = $_FILES['logo'];
  if ($file['error'] === UPLOAD_ERR_OK) {
    $allowed = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    $type = mime_content_type($file['tmp_name']);
    if (!isset($allowed[$type])) {
      $_SESSION['flash'] = ['error' => 'Format logo non supporté.'];
      header('Location: ' . $config['app']['base_url'] . '/?page=profile');
      exit;
    }
    if ($file['size'] > 2 * 1024 * 1024) {
      $_SESSION['flash'] = ['error' => 'Logo trop lourd (max 2 Mo).'];
      header('Location: ' . $config['app']['base_url'] . '/?page=profile');
      exit;
    }
    $ext = $allowed[$type];
    $name = 'logo_' . current_user_id() . '_' . bin2hex(random_bytes(6)) . '.' . $ext;
    $destFs = __DIR__ . '/../public/uploads/' . $name;
    if (!move_uploaded_file($file['tmp_name'], $destFs)) {
      $_SESSION['flash'] = ['error' => 'Upload impossible.'];
      header('Location: ' . $config['app']['base_url'] . '/?page=profile');
      exit;
    }
    $logo_path = $config['app']['base_url'] . '/uploads/' . $name;
  }
}

$fields = ['email' => $email, 'twitch_url' => ($twitch_url !== '' ? $twitch_url : null)];
$sql = 'UPDATE users SET email=:email, twitch_url=:twitch_url';

if ($logo_path !== null) {
  $sql .= ', logo_path=:logo_path';
  $fields['logo_path'] = $logo_path;
}

if (strlen($password) > 0) {
  if (strlen($password) < 6) {
    $_SESSION['flash'] = ['error' => 'Mot de passe trop court.'];
    header('Location: ' . $config['app']['base_url'] . '/?page=profile');
    exit;
  }
  $sql .= ', password_hash=:password_hash';
  $fields['password_hash'] = password_hash($password, PASSWORD_DEFAULT);
}

$sql .= ' WHERE id=:id';
$fields['id'] = current_user_id();

$stmt = $db->prepare($sql);
$stmt->execute($fields);

$_SESSION['flash'] = ['success' => 'Profil mis à jour.'];
header('Location: ' . $config['app']['base_url'] . '/?page=profile');
