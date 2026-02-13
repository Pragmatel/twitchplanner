<?php
session_start();

$config = require __DIR__ . '/../app/config/config.php';
$db = require __DIR__ . '/../app/config/db.php';

$email = trim($_POST['email'] ?? '');
$password = (string)($_POST['password'] ?? '');

if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 6) {
  $_SESSION['flash'] = ['error' => 'Email ou mot de passe invalide.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=register');
  exit;
}

$stmt = $db->prepare('SELECT id FROM users WHERE email=?');
$stmt->execute([$email]);
if ($stmt->fetch()) {
  $_SESSION['flash'] = ['error' => 'Cet email est déjà utilisé.'];
  header('Location: ' . $config['app']['base_url'] . '/?page=register');
  exit;
}

$hash = password_hash($password, PASSWORD_DEFAULT);
$stmt = $db->prepare('INSERT INTO users (email,password_hash) VALUES (?,?)');
$stmt->execute([$email, $hash]);

$_SESSION['flash'] = ['success' => 'Compte créé. Tu peux te connecter.'];
header('Location: ' . $config['app']['base_url'] . '/?page=login');
