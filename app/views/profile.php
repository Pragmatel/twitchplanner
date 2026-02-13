<?php $title='Profil'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?>
<div class="container py-5" style="max-width:760px">
  <h2 class="fw-bold mb-3">Mon profil</h2>
  <?php if(!empty($flash['error'])): ?><div class="alert alert-danger"><?php echo e($flash['error']); ?></div><?php endif; ?>
  <?php if(!empty($flash['success'])): ?><div class="alert alert-success"><?php echo e($flash['success']); ?></div><?php endif; ?>
  <div class="card p-4">
    <div class="d-flex align-items-center gap-3 mb-3">
      <?php if(!empty($user['logo_path'])): ?>
        <img src="<?php echo e($user['logo_path']); ?>" style="width:64px;height:64px;object-fit:cover;border-radius:12px;border:1px solid #2a2a35">
      <?php else: ?>
        <div style="width:64px;height:64px;border-radius:12px;background:rgba(145,70,255,.2);border:1px solid rgba(145,70,255,.35)"></div>
      <?php endif; ?>
      <div>
        <div class="fw-semibold"><?php echo e($user['email']); ?></div>
        <div class="small-muted"><?php echo e($user['twitch_url'] ?? ''); ?></div>
      </div>
    </div>
    <form method="post" action="../actions/profile_update.php" enctype="multipart/form-data">
      <div class="row g-3">
        <div class="col-md-6">
          <label class="form-label">Email</label>
          <input class="form-control" type="email" name="email" value="<?php echo e($user['email']); ?>" required>
        </div>
        <div class="col-md-6">
          <label class="form-label">Nouveau mot de passe</label>
          <input class="form-control" type="password" name="password" minlength="6">
        </div>
        <div class="col-md-8">
          <label class="form-label">URL Twitch</label>
          <input class="form-control" type="url" name="twitch_url" value="<?php echo e($user['twitch_url'] ?? ''); ?>">
        </div>
        <div class="col-md-4">
          <label class="form-label">Logo</label>
          <input class="form-control" type="file" name="logo" accept="image/png,image/jpeg,image/webp">
        </div>
      </div>
      <button class="btn btn-primary mt-4" type="submit">Enregistrer</button>
    </form>
  </div>
</div>
<?php require __DIR__ . '/partials/footer.php'; ?>
