<?php
session_start();

$config = require __DIR__ . '/../app/config/config.php';
session_destroy();
header('Location: ' . $config['app']['base_url'] . '/');
