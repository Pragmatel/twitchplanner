<?php $title='Connexion'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?>
<div class="container py-5" style="max-width:520px">
  <h2 class="fw-bold mb-3">Connexion</h2>
  <?php if(!empty($flash['error'])): ?><div class="alert alert-danger"><?php echo e($flash['error']); ?></div><?php endif; ?>
  <?php if(!empty($flash['success'])): ?><div class="alert alert-success"><?php echo e($flash['success']); ?></div><?php endif; ?>
  <div class="card p-4">
    <form method="post" action="../actions/auth_login.php">
      <div class="mb-3">
        <label class="form-label">Email</label>
        <input class="form-control" type="email" name="email" required>
      </div>
      <div class="mb-3">
        <label class="form-label">Mot de passe</label>
        <input class="form-control" type="password" name="password" required>
      </div>
      <button class="btn btn-primary w-100" type="submit">Se connecter</button>
    </form>
  </div>
</div>
<?php require __DIR__ . '/partials/footer.php'; ?>
