<?php $config = require __DIR__ . '/../../config/config.php'; ?>
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><?php echo e($title ?? 'TwitchPlanner'); ?></title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="<?php echo $config['app']['base_url']; ?>/assets/css/app.css" rel="stylesheet">
</head>
<body class="bg-dark text-light">
