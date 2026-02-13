<?php $config = require __DIR__ . '/../../config/config.php'; ?>
<nav class="navbar navbar-expand-lg navbar-dark bg-black border-bottom border-secondary">
  <div class="container">
    <a class="navbar-brand fw-bold" href="<?php echo $config['app']['base_url']; ?>/">TwitchPlanner</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="nav">
      <ul class="navbar-nav ms-auto">
        <?php if (current_user_id()): ?>
          <li class="nav-item"><a class="nav-link" href="<?php echo $config['app']['base_url']; ?>/?page=plannings">Plannings</a></li>
          <li class="nav-item"><a class="nav-link" href="<?php echo $config['app']['base_url']; ?>/?page=profile">Profil</a></li>
          <li class="nav-item"><a class="nav-link" href="<?php echo $config['app']['base_url']; ?>/../actions/auth_logout.php">Déconnexion</a></li>
        <?php else: ?>
          <li class="nav-item"><a class="nav-link" href="<?php echo $config['app']['base_url']; ?>/?page=login">Connexion</a></li>
          <li class="nav-item"><a class="nav-link" href="<?php echo $config['app']['base_url']; ?>/?page=register">Inscription</a></li>
        <?php endif; ?>
      </ul>
    </div>
  </div>
</nav>
