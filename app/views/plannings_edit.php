<?php $title='Planning'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?>
<div class="container py-4">
  <?php if(!empty($flash['error'])): ?><div class="alert alert-danger"><?php echo e($flash['error']); ?></div><?php endif; ?>
  <?php if(!empty($flash['success'])): ?><div class="alert alert-success"><?php echo e($flash['success']); ?></div><?php endif; ?>

  <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-3">
    <div>
      <h2 class="fw-bold m-0"><?php echo e($planning['title']); ?></h2>
      <div class="text-secondary">Semaine du <span class="badge badge-tp"><?php echo e($weekStart); ?></span></div>
    </div>
    <div class="d-flex gap-2 flex-wrap">
      <a class="btn btn-outline-light" href="?page=planning&id=<?php echo (int)$planning['id']; ?>&week=<?php echo e($prevWeek); ?>">Semaine précédente</a>
      <a class="btn btn-outline-light" href="?page=planning&id=<?php echo (int)$planning['id']; ?>&week=<?php echo e($nextWeek); ?>">Semaine suivante</a>
      <button class="btn btn-primary" id="exportPngBtn" type="button">Exporter en PNG</button>
    </div>
  </div>

  <div class="card p-3 mb-3">
    <form class="row g-2 align-items-end" method="post" action="../actions/planning_update.php">
      <input type="hidden" name="id" value="<?php echo (int)$planning['id']; ?>">
      <div class="col-md-6">
        <label class="form-label">Titre</label>
        <input class="form-control" name="title" value="<?php echo e($planning['title']); ?>" required>
      </div>
      <div class="col-md-4">
        <label class="form-label">Début de semaine (lundi)</label>
        <input class="form-control" type="date" name="week_start" value="<?php echo e($weekStart); ?>" required>
      </div>
      <div class="col-md-2 d-grid">
        <button class="btn btn-outline-light" type="submit">Mettre à jour</button>
      </div>
    </form>
  </div>

  <div id="planning-capture">
    <div class="planning-grid">
      <?php foreach($days as $day): ?>
        <div class="day-col">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <div>
              <div class="fw-semibold"><?php echo e($day['label']); ?></div>
              <div class="small-muted"><?php echo e($day['date']); ?></div>
            </div>
            <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#addEventModal<?php echo (int)$day['dow']; ?>">+</button>
          </div>

          <?php $list=$eventsByDay[$day['dow']] ?? []; ?>
          <?php if(empty($list)): ?>
            <div class="text-secondary small">Aucun événement</div>
          <?php else: ?>
            <?php foreach($list as $ev): ?>
              <div class="event-card">
                <?php if(!empty($ev['game_image_url'])): ?>
                  <img class="event-img mb-2" src="<?php echo e($ev['game_image_url']); ?>">
                <?php endif; ?>
                <div class="small-muted"><?php echo e(substr($ev['start_time'],0,5)); ?> - <?php echo e(substr($ev['end_time'],0,5)); ?></div>
                <div class="fw-semibold"><?php echo e($ev['game_name']); ?></div>
                <?php if(!empty($ev['stream_title'])): ?><div class="small-muted"><?php echo e($ev['stream_title']); ?></div><?php endif; ?>

                <div class="mt-2 d-flex gap-2">
                  <button class="btn btn-sm btn-outline-light" data-bs-toggle="collapse" data-bs-target="#editEvent<?php echo (int)$ev['id']; ?>">Modifier</button>
                  <form method="post" action="../actions/event_delete.php" onsubmit="return confirm('Supprimer cet événement ?');">
                    <input type="hidden" name="id" value="<?php echo (int)$ev['id']; ?>">
                    <input type="hidden" name="planning_id" value="<?php echo (int)$planning['id']; ?>">
                    <input type="hidden" name="week" value="<?php echo e($weekStart); ?>">
                    <button class="btn btn-sm btn-outline-danger" type="submit">Supprimer</button>
                  </form>
                </div>

                <div class="collapse mt-2" id="editEvent<?php echo (int)$ev['id']; ?>">
                  <form method="post" action="../actions/event_update.php">
                    <input type="hidden" name="id" value="<?php echo (int)$ev['id']; ?>">
                    <input type="hidden" name="planning_id" value="<?php echo (int)$planning['id']; ?>">
                    <input type="hidden" name="week" value="<?php echo e($weekStart); ?>">
                    <div class="mb-2">
                      <label class="form-label small">Nom du jeu</label>
                      <input class="form-control form-control-sm" name="game_name" value="<?php echo e($ev['game_name']); ?>" required>
                    </div>
                    <div class="mb-2">
                      <label class="form-label small">Image (URL)</label>
                      <input class="form-control form-control-sm" name="game_image_url" value="<?php echo e($ev['game_image_url'] ?? ''); ?>">
                    </div>
                    <div class="mb-2">
                      <label class="form-label small">Titre du stream</label>
                      <input class="form-control form-control-sm" name="stream_title" value="<?php echo e($ev['stream_title'] ?? ''); ?>">
                    </div>
                    <div class="row g-2">
                      <div class="col-6">
                        <label class="form-label small">Début</label>
                        <input class="form-control form-control-sm" type="time" name="start_time" value="<?php echo e(substr($ev['start_time'],0,5)); ?>" required>
                      </div>
                      <div class="col-6">
                        <label class="form-label small">Fin</label>
                        <input class="form-control form-control-sm" type="time" name="end_time" value="<?php echo e(substr($ev['end_time'],0,5)); ?>" required>
                      </div>
                    </div>
                    <button class="btn btn-sm btn-primary w-100 mt-2" type="submit">Enregistrer</button>
                  </form>
                </div>
              </div>
            <?php endforeach; ?>
          <?php endif; ?>
        </div>

        <div class="modal fade" id="addEventModal<?php echo (int)$day['dow']; ?>" tabindex="-1">
          <div class="modal-dialog">
            <div class="modal-content bg-dark text-light border-secondary">
              <div class="modal-header border-secondary">
                <h5 class="modal-title">Ajouter un événement — <?php echo e($day['label']); ?></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
              </div>
              <form method="post" action="../actions/event_create.php">
                <div class="modal-body">
                  <input type="hidden" name="planning_id" value="<?php echo (int)$planning['id']; ?>">
                  <input type="hidden" name="day_of_week" value="<?php echo (int)$day['dow']; ?>">
                  <input type="hidden" name="week" value="<?php echo e($weekStart); ?>">
                  <div class="mb-3">
                    <label class="form-label">Nom du jeu</label>
                    <input class="form-control" name="game_name" required>
                  </div>
                  <div class="mb-3">
                    <label class="form-label">Image (URL)</label>
                    <input class="form-control" name="game_image_url">
                  </div>
                  <div class="mb-3">
                    <label class="form-label">Titre du stream</label>
                    <input class="form-control" name="stream_title">
                  </div>
                  <div class="row g-2">
                    <div class="col-6">
                      <label class="form-label">Début</label>
                      <input class="form-control" type="time" name="start_time" required>
                    </div>
                    <div class="col-6">
                      <label class="form-label">Fin</label>
                      <input class="form-control" type="time" name="end_time" required>
                    </div>
                  </div>
                </div>
                <div class="modal-footer border-secondary">
                  <button class="btn btn-outline-light" type="button" data-bs-dismiss="modal">Annuler</button>
                  <button class="btn btn-primary" type="submit">Ajouter</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      <?php endforeach; ?>
    </div>
  </div>
</div>
<?php require __DIR__ . '/partials/footer.php'; ?>
