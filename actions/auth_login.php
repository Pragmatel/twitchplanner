<?php
session_start();

$config = require __DIR__ . '/../app/config/config.php';
$db = require __DIR__ . '/../app/config/db.php';

$email = trim($_POST['email'] ?? '');
$password = (string)($_POST['password'] ?? '');

$stmt = $db->prepare('SELECT id,password_hash FROM users WHERE email=?');
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
  $_SESSION['flash'] = ['error' => 'Identifiants incorrects.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=login');
  exit;
}

$_SESSION['user_id'] = (int)$user['id'];
header('Location: ' . $config['app']['base_url'] . '/?page=plannings');
