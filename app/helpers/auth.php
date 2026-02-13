<?php
function current_user_id() {
  return $_SESSION['user_id'] ?? null;
}

function require_auth($baseUrl) {
  if (!current_user_id()) {
    header('Location: ' . $baseUrl . '/?page=login');
    exit;
  }
}

function e($str) {
  return htmlspecialchars((string)$str, ENT_QUOTES, 'UTF-8');
}
