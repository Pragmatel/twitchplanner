<?php $title='Accueil'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?>
<div class="container py-5">
  <div class="row align-items-center g-4">
    <div class="col-lg-6">
      <h1 class="display-5 fw-bold">Planifie tes streams comme un pro</h1>
      <p class="lead text-secondary">Crée ton planning hebdomadaire, ajoute tes streams, et exporte ton planning en image pour tes réseaux.</p>
      <div class="d-flex gap-2">
        <a class="btn btn-primary btn-lg" href="?page=register">Créer un compte</a>
        <a class="btn btn-outline-light btn-lg" href="?page=login">Se connecter</a>
      </div>
    </div>
    <div class="col-lg-6">
      <div class="card p-4">
        <div class="planning-grid">
          <?php for($i=0;$i<7;$i++): ?>
            <div class="day-col">
              <div class="fw-semibold">Jour <?php echo $i+1; ?></div>
              <div class="event-card mt-2">
                <div class="small-muted">19:00 - 21:00</div>
                <div class="fw-semibold">Just Chatting</div>
                <div class="small-muted">Titre optionnel</div>
              </div>
            </div>
          <?php endfor; ?>
        </div>
      </div>
    </div>
  </div>
</div>
<?php require __DIR__ . '/partials/footer.php'; ?>
