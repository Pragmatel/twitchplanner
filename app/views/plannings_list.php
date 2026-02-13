<?php $title='Mes plannings'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?>
<div class="container py-5">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="fw-bold m-0">Mes plannings</h2>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createPlanningModal">Créer un planning</button>
  </div>

  <?php if(!empty($flash['error'])): ?><div class="alert alert-danger"><?php echo e($flash['error']); ?></div><?php endif; ?>
  <?php if(!empty($flash['success'])): ?><div class="alert alert-success"><?php echo e($flash['success']); ?></div><?php endif; ?>

  <div class="card p-3">
    <?php if(empty($plannings)): ?>
      <div class="text-secondary">Aucun planning.</div>
    <?php else: ?>
      <div class="table-responsive">
        <table class="table table-dark table-hover align-middle mb-0">
          <thead>
            <tr>
              <th>Titre</th>
              <th>Semaine</th>
              <th class="text-end">Actions</th>
            </tr>
          </thead>
          <tbody>
            <?php foreach($plannings as $p): ?>
              <tr>
                <td class="fw-semibold"><?php echo e($p['title']); ?></td>
                <td><span class="badge badge-tp"><?php echo e($p['week_start']); ?></span></td>
                <td class="text-end">
                  <a class="btn btn-sm btn-outline-light" href="?page=planning&id=<?php echo (int)$p['id']; ?>">Modifier</a>
                  <form class="d-inline" method="post" action="../actions/planning_delete.php" onsubmit="return confirm('Supprimer ce planning ?');">
                    <input type="hidden" name="id" value="<?php echo (int)$p['id']; ?>">
                    <button class="btn btn-sm btn-outline-danger" type="submit">Supprimer</button>
                  </form>
                </td>
              </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
      </div>
    <?php endif; ?>
  </div>
</div>

<div class="modal fade" id="createPlanningModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content bg-dark text-light border-secondary">
      <div class="modal-header border-secondary">
        <h5 class="modal-title">Créer un planning</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <form method="post" action="../actions/planning_create.php">
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label">Titre</label>
            <input class="form-control" name="title" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Début de semaine (lundi)</label>
            <input class="form-control" type="date" name="week_start" value="<?php echo e($defaultWeekStart); ?>" required>
          </div>
        </div>
        <div class="modal-footer border-secondary">
          <button class="btn btn-outline-light" type="button" data-bs-dismiss="modal">Annuler</button>
          <button class="btn btn-primary" type="submit">Créer</button>
        </div>
      </form>
    </div>
  </div>
</div>

<?php require __DIR__ . '/partials/footer.php'; ?>
