$ErrorActionPreference = "Stop"
$root = Get-Location

$dirs = @(
  "public",
  "public\assets",
  "public\assets\css",
  "public\assets\js",
  "public\assets\img",
  "public\uploads",
  "app",
  "app\config",
  "app\helpers",
  "app\views",
  "app\views\partials",
  "actions"
)

foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

function WriteFile($path, $content) {
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText((Join-Path $root $path), $content, $utf8)
}

WriteFile ".gitignore" @"
.vscode/
.DS_Store
Thumbs.db
public/uploads/*
!public/uploads/.gitkeep
app/config/config.php
"@

WriteFile "public/uploads/.gitkeep" @"
"@

WriteFile "database.sql" @"
CREATE DATABASE IF NOT EXISTS twitchplanner CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE twitchplanner;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  twitch_url VARCHAR(255) NULL,
  logo_path VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE plannings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(120) NOT NULL,
  week_start DATE NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_plannings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  planning_id INT NOT NULL,
  game_name VARCHAR(120) NOT NULL,
  game_image_url VARCHAR(255) NULL,
  stream_title VARCHAR(160) NULL,
  day_of_week TINYINT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_events_planning FOREIGN KEY (planning_id) REFERENCES plannings(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_plannings_user ON plannings(user_id);
CREATE INDEX idx_events_planning_day ON events(planning_id, day_of_week);
"@

WriteFile "README.md" @"
# TwitchPlanner

## Prérequis
- XAMPP (Apache + MySQL)
- phpMyAdmin
- VS Code

## Installation
1. Mettre le dossier dans `xampp/htdocs/twitchplanner`
2. Démarrer Apache et MySQL dans XAMPP
3. Importer `database.sql` via phpMyAdmin
4. Copier `app/config/config.example.php` vers `app/config/config.php` et adapter
5. Ouvrir `http://localhost/twitchplanner/public/`

## Git
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <URL>
git push -u origin main
"@

WriteFile "app/config/config.example.php" 
@"

<?php return [ 'db' => [ 'host' => '127.0.0.1', 'name' => 'twitchplanner', 'user' => 'root', 'pass' => '', 'charset' => 'utf8mb4' ], 'app' => [ 'base_url' => '/twitchplanner/public' ] ]; "@ 
WriteFile "app/config/db.php" 
@" 
<?php $config = require __DIR__ . '/config.php'; $dsn = 'mysql:host=' . $config['db']['host'] . ';dbname=' . $config['db']['name'] . ';charset=' . $config['db']['charset']; $options = [ PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES => false ]; return new PDO($dsn, $config['db']['user'], $config['db']['pass'], $options); 
"@ 
WriteFile "app/helpers/auth.php" 
@" 
<?php function current_user_id() { return $_SESSION['user_id'] ?? null; } function require_auth($baseUrl) { if (!current_user_id()) { header('Location: ' . $baseUrl . '/?page=login'); exit; } } function e($str) { return htmlspecialchars((string)$str, ENT_QUOTES, 'UTF-8'); } 
"@ 
WriteFile "app/helpers/weeks.php" 
@" 
<?php function week_start_from_date($dateStr) { $dt = new DateTime($dateStr); $day = (int)$dt->format('N'); $dt->modify('-' . ($day - 1) . ' days'); return $dt->format('Y-m-d'); } function week_range($weekStart) { $start = new DateTime($weekStart); $days = []; for ($i = 0; $i < 7; $i++) { $d = clone $start; $d->modify('+' . $i . ' days'); $days[] = [ 'date' => $d->format('Y-m-d'), 'label' => $d->format('D d/m'), 'dow' => $i ]; } return $days; } function add_days($dateStr, $days) { $dt = new DateTime($dateStr); $dt->modify(($days >= 0 ? '+' : '') . $days . ' days'); return $dt->format('Y-m-d'); } 
"@ 
WriteFile "public/assets/css/app.css" 
@" 
:root{--tp-purple:#9146ff} a{color:var(--tp-purple)} .btn-primary{background:var(--tp-purple);border-color:var(--tp-purple)} .btn-primary:hover{opacity:.9} .card{background:#0f0f13;border-color:#2a2a35} .form-control,.form-select{background:#111118;color:#f1f1f1;border-color:#2a2a35} .form-control:focus,.form-select:focus{border-color:var(--tp-purple);box-shadow:0 0 0 .25rem rgba(145,70,255,.25)} .table{--bs-table-bg:transparent} .badge-tp{background:rgba(145,70,255,.15);color:#d9c7ff;border:1px solid rgba(145,70,255,.35)} .planning-grid{display:grid;grid-template-columns:repeat(7,1fr);gap:12px} .day-col{border:1px solid #2a2a35;border-radius:10px;padding:10px;min-height:240px;background:#0b0b10} .event-card{border:1px solid #2a2a35;border-radius:10px;padding:10px;margin-bottom:10px;background:#0f0f13} .event-img{width:100%;height:110px;object-fit:cover;border-radius:8px;border:1px solid #2a2a35} .small-muted{color:#b8b8c9;font-size:.9rem} 
"@ 
WriteFile "public/assets/js/app.js" 
@" 
document.addEventListener('DOMContentLoaded',()=>{const b=document.getElementById('exportPngBtn');if(!b)return;b.addEventListener('click',async()=>{const e=document.getElementById('planning-capture');if(!e)return;const c=await html2canvas(e,{scale:2,useCORS:true,backgroundColor:null});const a=document.createElement('a');a.download='planning.png';a.href=c.toDataURL('image/png');a.click();});}); 
"@ 
WriteFile "app/views/partials/head.php" 
@" 
<?php $config = require __DIR__ . '/../../config/config.php'; ?> <!doctype html> <html lang=""fr""> <head> <meta charset=""utf-8""> <meta name=""viewport"" content=""width=device-width, initial-scale=1""> <title><?php echo e($title ?? 'TwitchPlanner'); ?></title> <link href=""https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"" rel=""stylesheet""> <link href=""<?php echo $config['app']['base_url']; ?>/assets/css/app.css"" rel=""stylesheet""> </head> <body class=""bg-dark text-light""> 
"@

WriteFile "app/views/partials/nav.php" 
@"

<?php $config = require __DIR__ . '/../../config/config.php'; ?> <nav class=""navbar navbar-expand-lg navbar-dark bg-black border-bottom border-secondary""> <div class=""container""> <a class=""navbar-brand fw-bold"" href=""<?php echo $config['app']['base_url']; ?>/"">TwitchPlanner</a> <button class=""navbar-toggler"" type=""button"" data-bs-toggle=""collapse"" data-bs-target=""#nav""> <span class=""navbar-toggler-icon""></span> </button> <div class=""collapse navbar-collapse"" id=""nav""> <ul class=""navbar-nav ms-auto""> <?php if (current_user_id()): ?> <li class=""nav-item""><a class=""nav-link"" href=""<?php echo $config['app']['base_url']; ?>/?page=plannings"">Plannings</a></li> <li class=""nav-item""><a class=""nav-link"" href=""<?php echo $config['app']['base_url']; ?>/?page=profile"">Profil</a></li> <li class=""nav-item""><a class=""nav-link"" href=""<?php echo $config['app']['base_url']; ?>/../actions/auth_logout.php"">Déconnexion</a></li> <?php else: ?> <li class=""nav-item""><a class=""nav-link"" href=""<?php echo $config['app']['base_url']; ?>/?page=login"">Connexion</a></li> <li class=""nav-item""><a class=""nav-link"" href=""<?php echo $config['app']['base_url']; ?>/?page=register"">Inscription</a></li> <?php endif; ?> </ul> </div> </div> </nav> "@

WriteFile "app/views/partials/footer.php" @"

<script src=""https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js""></script> <script src=""https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js""></script> <script src=""<?php echo (require __DIR__ . '/../../config/config.php')['app']['base_url']; ?>/assets/js/app.js""></script> </body> </html> "@

WriteFile "app/views/home.php" @"

<?php $title='Accueil'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?> <div class=""container py-5""> <div class=""row align-items-center g-4""> <div class=""col-lg-6""> <h1 class=""display-5 fw-bold"">Planifie tes streams comme un pro</h1> <p class=""lead text-secondary"">Crée ton planning hebdomadaire, ajoute tes streams, et exporte ton planning en image pour tes réseaux.</p> <div class=""d-flex gap-2""> <a class=""btn btn-primary btn-lg"" href=""?page=register"">Créer un compte</a> <a class=""btn btn-outline-light btn-lg"" href=""?page=login"">Se connecter</a> </div> </div> <div class=""col-lg-6""> <div class=""card p-4""> <div class=""planning-grid""> <?php for($i=0;$i<7;$i++): ?> <div class=""day-col""> <div class=""fw-semibold"">Jour <?php echo $i+1; ?></div> <div class=""event-card mt-2""> <div class=""small-muted"">19:00 - 21:00</div> <div class=""fw-semibold"">Just Chatting</div> <div class=""small-muted"">Titre optionnel</div> </div> </div> <?php endfor; ?> </div> </div> </div> </div> </div> <?php require __DIR__ . '/partials/footer.php'; ?> "@

WriteFile "app/views/auth_register.php" @"

<?php $title='Inscription'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?> <div class=""container py-5"" style=""max-width:520px""> <h2 class=""fw-bold mb-3"">Créer un compte</h2> <?php if(!empty($flash['error'])): ?><div class=""alert alert-danger""><?php echo e($flash['error']); ?></div><?php endif; ?> <?php if(!empty($flash['success'])): ?><div class=""alert alert-success""><?php echo e($flash['success']); ?></div><?php endif; ?> <div class=""card p-4""> <form method=""post"" action=""../actions/auth_register.php""> <div class=""mb-3""> <label class=""form-label"">Email</label> <input class=""form-control"" type=""email"" name=""email"" required> </div> <div class=""mb-3""> <label class=""form-label"">Mot de passe</label> <input class=""form-control"" type=""password"" name=""password"" minlength=""6"" required> </div> <button class=""btn btn-primary w-100"" type=""submit"">Créer</button> </form> </div> </div> <?php require __DIR__ . '/partials/footer.php'; ?> "@

WriteFile "app/views/auth_login.php" @"

<?php $title='Connexion'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?> <div class=""container py-5"" style=""max-width:520px""> <h2 class=""fw-bold mb-3"">Connexion</h2> <?php if(!empty($flash['error'])): ?><div class=""alert alert-danger""><?php echo e($flash['error']); ?></div><?php endif; ?> <?php if(!empty($flash['success'])): ?><div class=""alert alert-success""><?php echo e($flash['success']); ?></div><?php endif; ?> <div class=""card p-4""> <form method=""post"" action=""../actions/auth_login.php""> <div class=""mb-3""> <label class=""form-label"">Email</label> <input class=""form-control"" type=""email"" name=""email"" required> </div> <div class=""mb-3""> <label class=""form-label"">Mot de passe</label> <input class=""form-control"" type=""password"" name=""password"" required> </div> <button class=""btn btn-primary w-100"" type=""submit"">Se connecter</button> </form> </div> </div> <?php require __DIR__ . '/partials/footer.php'; ?> "@

WriteFile "app/views/profile.php" @"

<?php $title='Profil'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?> <div class=""container py-5"" style=""max-width:760px""> <h2 class=""fw-bold mb-3"">Mon profil</h2> <?php if(!empty($flash['error'])): ?><div class=""alert alert-danger""><?php echo e($flash['error']); ?></div><?php endif; ?> <?php if(!empty($flash['success'])): ?><div class=""alert alert-success""><?php echo e($flash['success']); ?></div><?php endif; ?> <div class=""card p-4""> <div class=""d-flex align-items-center gap-3 mb-3""> <?php if(!empty($user['logo_path'])): ?> <img src=""<?php echo e($user['logo_path']); ?>"" style=""width:64px;height:64px;object-fit:cover;border-radius:12px;border:1px solid #2a2a35""> <?php else: ?> <div style=""width:64px;height:64px;border-radius:12px;background:rgba(145,70,255,.2);border:1px solid rgba(145,70,255,.35)""></div> <?php endif; ?> <div> <div class=""fw-semibold""><?php echo e($user['email']); ?></div> <div class=""small-muted""><?php echo e($user['twitch_url'] ?? ''); ?></div> </div> </div> <form method=""post"" action=""../actions/profile_update.php"" enctype=""multipart/form-data""> <div class=""row g-3""> <div class=""col-md-6""> <label class=""form-label"">Email</label> <input class=""form-control"" type=""email"" name=""email"" value=""<?php echo e($user['email']); ?>"" required> </div> <div class=""col-md-6""> <label class=""form-label"">Nouveau mot de passe</label> <input class=""form-control"" type=""password"" name=""password"" minlength=""6""> </div> <div class=""col-md-8""> <label class=""form-label"">URL Twitch</label> <input class=""form-control"" type=""url"" name=""twitch_url"" value=""<?php echo e($user['twitch_url'] ?? ''); ?>""> </div> <div class=""col-md-4""> <label class=""form-label"">Logo</label> <input class=""form-control"" type=""file"" name=""logo"" accept=""image/png,image/jpeg,image/webp""> </div> </div> <button class=""btn btn-primary mt-4"" type=""submit"">Enregistrer</button> </form> </div> </div> <?php require __DIR__ . '/partials/footer.php'; ?> "@

WriteFile "app/views/plannings_list.php" @"

<?php $title='Mes plannings'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?> <div class=""container py-5""> <div class=""d-flex align-items-center justify-content-between mb-3""> <h2 class=""fw-bold m-0"">Mes plannings</h2> <button class=""btn btn-primary"" data-bs-toggle=""modal"" data-bs-target=""#createPlanningModal"">Créer un planning</button> </div> <?php if(!empty($flash['error'])): ?><div class=""alert alert-danger""><?php echo e($flash['error']); ?></div><?php endif; ?> <?php if(!empty($flash['success'])): ?><div class=""alert alert-success""><?php echo e($flash['success']); ?></div><?php endif; ?> <div class=""card p-3""> <?php if(empty($plannings)): ?> <div class=""text-secondary"">Aucun planning.</div> <?php else: ?> <div class=""table-responsive""> <table class=""table table-dark table-hover align-middle mb-0""> <thead> <tr> <th>Titre</th> <th>Semaine</th> <th class=""text-end"">Actions</th> </tr> </thead> <tbody> <?php foreach($plannings as $p): ?> <tr> <td class=""fw-semibold""><?php echo e($p['title']); ?></td> <td><span class=""badge badge-tp""><?php echo e($p['week_start']); ?></span></td> <td class=""text-end""> <a class=""btn btn-sm btn-outline-light"" href=""?page=planning&id=<?php echo (int)$p['id']; ?>"">Modifier</a> <form class=""d-inline"" method=""post"" action=""../actions/planning_delete.php"" onsubmit=""return confirm('Supprimer ce planning ?');""> <input type=""hidden"" name=""id"" value=""<?php echo (int)$p['id']; ?>""> <button class=""btn btn-sm btn-outline-danger"" type=""submit"">Supprimer</button> </form> </td> </tr> <?php endforeach; ?> </tbody> </table> </div> <?php endif; ?> </div> </div> <div class=""modal fade"" id=""createPlanningModal"" tabindex=""-1""> <div class=""modal-dialog""> <div class=""modal-content bg-dark text-light border-secondary""> <div class=""modal-header border-secondary""> <h5 class=""modal-title"">Créer un planning</h5> <button type=""button"" class=""btn-close btn-close-white"" data-bs-dismiss=""modal""></button> </div> <form method=""post"" action=""../actions/planning_create.php""> <div class=""modal-body""> <div class=""mb-3""> <label class=""form-label"">Titre</label> <input class=""form-control"" name=""title"" required> </div> <div class=""mb-3""> <label class=""form-label"">Début de semaine (lundi)</label> <input class=""form-control"" type=""date"" name=""week_start"" value=""<?php echo e($defaultWeekStart); ?>"" required> </div> </div> <div class=""modal-footer border-secondary""> <button class=""btn btn-outline-light"" type=""button"" data-bs-dismiss=""modal"">Annuler</button> <button class=""btn btn-primary"" type=""submit"">Créer</button> </div> </form> </div> </div> </div> <?php require __DIR__ . '/partials/footer.php'; ?>

"@

WriteFile "app/views/planning_edit.php" @"

<?php $title='Planning'; require __DIR__ . '/partials/head.php'; require __DIR__ . '/partials/nav.php'; ?> <div class=""container py-4""> <?php if(!empty($flash['error'])): ?><div class=""alert alert-danger""><?php echo e($flash['error']); ?></div><?php endif; ?> <?php if(!empty($flash['success'])): ?><div class=""alert alert-success""><?php echo e($flash['success']); ?></div><?php endif; ?> <div class=""d-flex flex-wrap align-items-center justify-content-between gap-2 mb-3""> <div> <h2 class=""fw-bold m-0""><?php echo e($planning['title']); ?></h2> <div class=""text-secondary"">Semaine du <span class=""badge badge-tp""><?php echo e($weekStart); ?></span></div> </div> <div class=""d-flex gap-2 flex-wrap""> <a class=""btn btn-outline-light"" href=""?page=planning&id=<?php echo (int)$planning['id']; ?>&week=<?php echo e($prevWeek); ?>"">Semaine précédente</a> <a class=""btn btn-outline-light"" href=""?page=planning&id=<?php echo (int)$planning['id']; ?>&week=<?php echo e($nextWeek); ?>"">Semaine suivante</a> <button class=""btn btn-primary"" id=""exportPngBtn"" type=""button"">Exporter en PNG</button> </div> </div> <div class=""card p-3 mb-3""> <form class=""row g-2 align-items-end"" method=""post"" action=""../actions/planning_update.php""> <input type=""hidden"" name=""id"" value=""<?php echo (int)$planning['id']; ?>""> <div class=""col-md-6""> <label class=""form-label"">Titre</label> <input class=""form-control"" name=""title"" value=""<?php echo e($planning['title']); ?>"" required> </div> <div class=""col-md-4""> <label class=""form-label"">Début de semaine (lundi)</label> <input class=""form-control"" type=""date"" name=""week_start"" value=""<?php echo e($weekStart); ?>"" required> </div> <div class=""col-md-2 d-grid""> <button class=""btn btn-outline-light"" type=""submit"">Mettre à jour</button> </div> </form> </div> <div id=""planning-capture""> <div class=""planning-grid""> <?php foreach($days as $day): ?> <div class=""day-col""> <div class=""d-flex align-items-center justify-content-between mb-2""> <div> <div class=""fw-semibold""><?php echo e($day['label']); ?></div> <div class=""small-muted""><?php echo e($day['date']); ?></div> </div> <button class=""btn btn-sm btn-primary"" data-bs-toggle=""modal"" data-bs-target=""#addEventModal<?php echo (int)$day['dow']; ?>"">+</button> </div>
      <?php $list=$eventsByDay[$day['dow']] ?? []; ?>
      <?php if(empty($list)): ?>
        <div class=""text-secondary small"">Aucun événement</div>
      <?php else: ?>
        <?php foreach($list as $ev): ?>
          <div class=""event-card"">
            <?php if(!empty($ev['game_image_url'])): ?>
              <img class=""event-img mb-2"" src=""<?php echo e($ev['game_image_url']); ?>"">
            <?php endif; ?>
            <div class=""small-muted""><?php echo e(substr($ev['start_time'],0,5)); ?> - <?php echo e(substr($ev['end_time'],0,5)); ?></div>
            <div class=""fw-semibold""><?php echo e($ev['game_name']); ?></div>
            <?php if(!empty($ev['stream_title'])): ?><div class=""small-muted""><?php echo e($ev['stream_title']); ?></div><?php endif; ?>

            <div class=""mt-2 d-flex gap-2"">
              <button class=""btn btn-sm btn-outline-light"" data-bs-toggle=""collapse"" data-bs-target=""#editEvent<?php echo (int)$ev['id']; ?>"">Modifier</button>
              <form method=""post"" action=""../actions/event_delete.php"" onsubmit=""return confirm('Supprimer cet événement ?');"">
                <input type=""hidden"" name=""id"" value=""<?php echo (int)$ev['id']; ?>"">
                <input type=""hidden"" name=""planning_id"" value=""<?php echo (int)$planning['id']; ?>"">
                <input type=""hidden"" name=""week"" value=""<?php echo e($weekStart); ?>"">
                <button class=""btn btn-sm btn-outline-danger"" type=""submit"">Supprimer</button>
              </form>
            </div>

            <div class=""collapse mt-2"" id=""editEvent<?php echo (int)$ev['id']; ?>"">
              <form method=""post"" action=""../actions/event_update.php"">
                <input type=""hidden"" name=""id"" value=""<?php echo (int)$ev['id']; ?>"">
                <input type=""hidden"" name=""planning_id"" value=""<?php echo (int)$planning['id']; ?>"">
                <input type=""hidden"" name=""week"" value=""<?php echo e($weekStart); ?>"">
                <div class=""mb-2"">
                  <label class=""form-label small"">Nom du jeu</label>
                  <input class=""form-control form-control-sm"" name=""game_name"" value=""<?php echo e($ev['game_name']); ?>"" required>
                </div>
                <div class=""mb-2"">
                  <label class=""form-label small"">Image (URL)</label>
                  <input class=""form-control form-control-sm"" name=""game_image_url"" value=""<?php echo e($ev['game_image_url'] ?? ''); ?>"">
                </div>
                <div class=""mb-2"">
                  <label class=""form-label small"">Titre du stream</label>
                  <input class=""form-control form-control-sm"" name=""stream_title"" value=""<?php echo e($ev['stream_title'] ?? ''); ?>"">
                </div>
                <div class=""row g-2"">
                  <div class=""col-6"">
                    <label class=""form-label small"">Début</label>
                    <input class=""form-control form-control-sm"" type=""time"" name=""start_time"" value=""<?php echo e(substr($ev['start_time'],0,5)); ?>"" required>
                  </div>
                  <div class=""col-6"">
                    <label class=""form-label small"">Fin</label>
                    <input class=""form-control form-control-sm"" type=""time"" name=""end_time"" value=""<?php echo e(substr($ev['end_time'],0,5)); ?>"" required>
                  </div>
                </div>
                <button class=""btn btn-sm btn-primary w-100 mt-2"" type=""submit"">Enregistrer</button>
              </form>
            </div>

          </div>
        <?php endforeach; ?>
      <?php endif; ?>
    </div>

    <div class=""modal fade"" id=""addEventModal<?php echo (int)$day['dow']; ?>"" tabindex=""-1"">
      <div class=""modal-dialog"">
        <div class=""modal-content bg-dark text-light border-secondary"">
          <div class=""modal-header border-secondary"">
            <h5 class=""modal-title"">Ajouter un événement — <?php echo e($day['label']); ?></h5>
            <button type=""button"" class=""btn-close btn-close-white"" data-bs-dismiss=""modal""></button>
          </div>
          <form method=""post"" action=""../actions/event_create.php"">
            <div class=""modal-body"">
              <input type=""hidden"" name=""planning_id"" value=""<?php echo (int)$planning['id']; ?>"">
              <input type=""hidden"" name=""day_of_week"" value=""<?php echo (int)$day['dow']; ?>"">
              <input type=""hidden"" name=""week"" value=""<?php echo e($weekStart); ?>"">
              <div class=""mb-3"">
                <label class=""form-label"">Nom du jeu</label>
                <input class=""form-control"" name=""game_name"" required>
              </div>
              <div class=""mb-3"">
                <label class=""form-label"">Image (URL)</label>
                <input class=""form-control"" name=""game_image_url"">
              </div>
              <div class=""mb-3"">
                <label class=""form-label"">Titre du stream</label>
                <input class=""form-control"" name=""stream_title"">
              </div>
              <div class=""row g-2"">
                <div class=""col-6"">
                  <label class=""form-label"">Début</label>
                  <input class=""form-control"" type=""time"" name=""start_time"" required>
                </div>
                <div class=""col-6"">
                  <label class=""form-label"">Fin</label>
                  <input class=""form-control"" type=""time"" name=""end_time"" required>
                </div>
              </div>
            </div>
            <div class=""modal-footer border-secondary"">
              <button class=""btn btn-outline-light"" type=""button"" data-bs-dismiss=""modal"">Annuler</button>
              <button class=""btn btn-primary"" type=""submit"">Ajouter</button>
            </div>
          </form>
        </div>
      </div>
    </div>

  <?php endforeach; ?>
</div>

</div> </div> <?php require __DIR__ . '/partials/footer.php'; ?> "@

WriteFile "public/index.php" @"

<?php session_start(); require __DIR__ . '/../app/helpers/auth.php'; require __DIR__ . '/../app/helpers/weeks.php'; $configPath = __DIR__ . '/../app/config/config.php'; if (!file_exists($configPath)) { http_response_code(500); echo '<div style=""font-family:Arial;padding:24px""><h2>Config manquante</h2><p>Copie app/config/config.example.php vers app/config/config.php</p></div>'; exit; } $config = require $configPath; $flash = $_SESSION['flash'] ?? []; unset($_SESSION['flash']); $page = $_GET['page'] ?? 'home'; $db = require __DIR__ . '/../app/config/db.php'; if ($page === 'home') { require __DIR__ . '/../app/views/home.php'; exit; } if ($page === 'register') { if (current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } require __DIR__ . '/../app/views/auth_register.php'; exit; } if ($page === 'login') { if (current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } require __DIR__ . '/../app/views/auth_login.php'; exit; } if ($page === 'profile') { require_auth($config['app']['base_url']); $stmt = $db->prepare('SELECT id,email,twitch_url,logo_path FROM users WHERE id=?'); $stmt->execute([current_user_id()]); $user = $stmt->fetch(); require __DIR__ . '/../app/views/profile.php'; exit; } if ($page === 'plannings') { require_auth($config['app']['base_url']); $today = (new DateTime())->format('Y-m-d'); $defaultWeekStart = week_start_from_date($today); $stmt = $db->prepare('SELECT id,title,week_start FROM plannings WHERE user_id=? ORDER BY created_at DESC'); $stmt->execute([current_user_id()]); $plannings = $stmt->fetchAll(); require __DIR__ . '/../app/views/plannings_list.php'; exit; } if ($page === 'planning') { require_auth($config['app']['base_url']); $id = isset($_GET['id']) ? (int)$_GET['id'] : 0; if ($id <= 0) { header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $stmt = $db->prepare('SELECT id,user_id,title,week_start FROM plannings WHERE id=?'); $stmt->execute([$id]); $planning = $stmt->fetch(); if (!$planning || (int)$planning['user_id'] !== (int)current_user_id()) { $_SESSION['flash'] = ['error' => 'Accès refusé.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $weekStart = $_GET['week'] ?? $planning['week_start']; $weekStart = week_start_from_date($weekStart); $days = week_range($weekStart); $prevWeek = add_days($weekStart, -7); $nextWeek = add_days($weekStart, 7); $stmt = $db->prepare('SELECT id,planning_id,game_name,game_image_url,stream_title,day_of_week,start_time,end_time FROM events WHERE planning_id=? ORDER BY day_of_week ASC, start_time ASC'); $stmt->execute([$planning['id']]); $events = $stmt->fetchAll(); $eventsByDay = []; foreach ($events as $ev) { $dow = (int)$ev['day_of_week']; if (!isset($eventsByDay[$dow])) $eventsByDay[$dow] = []; $eventsByDay[$dow][] = $ev; } require __DIR__ . '/../app/views/planning_edit.php'; exit; } http_response_code(404); echo 'Page introuvable'; "@ WriteFile "actions/auth_register.php" @" <?php session_start(); $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; $email = trim($_POST['email'] ?? ''); $password = (string)($_POST['password'] ?? ''); if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 6) { $_SESSION['flash'] = ['error' => 'Email ou mot de passe invalide.']; header('Location: ' . $config['app']['base_url'] . '/?page=register'); exit; } $stmt = $db->prepare('SELECT id FROM users WHERE email=?'); $stmt->execute([$email]); if ($stmt->fetch()) { $_SESSION['flash'] = ['error' => 'Cet email est déjà utilisé.']; header('Location: ' . $config['app']['base_url'] . '/?page=register'); exit; } $hash = password_hash($password, PASSWORD_DEFAULT); $stmt = $db->prepare('INSERT INTO users (email,password_hash) VALUES (?,?)'); $stmt->execute([$email, $hash]); $_SESSION['flash'] = ['success' => 'Compte créé. Tu peux te connecter.']; header('Location: ' . $config['app']['base_url'] . '/?page=login'); "@ WriteFile "actions/auth_login.php" @" <?php session_start(); $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; $email = trim($_POST['email'] ?? ''); $password = (string)($_POST['password'] ?? ''); $stmt = $db->prepare('SELECT id,password_hash FROM users WHERE email=?'); $stmt->execute([$email]); $user = $stmt->fetch(); if (!$user || !password_verify($password, $user['password_hash'])) { $_SESSION['flash'] = ['error' => 'Identifiants incorrects.']; header('Location: ' . $config['app']['base_url'] . '/?page=login'); exit; } $_SESSION['user_id'] = (int)$user['id']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); "@ WriteFile "actions/auth_logout.php" @" <?php session_start(); $config = require __DIR__ . '/../app/config/config.php'; session_destroy(); header('Location: ' . $config['app']['base_url'] . '/'); "@ WriteFile "actions/profile_update.php" @" <?php session_start(); require __DIR__ . '/../app/helpers/auth.php'; $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; if (!current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=login'); exit; } $email = trim($_POST['email'] ?? ''); $password = (string)($_POST['password'] ?? ''); $twitch_url = trim($_POST['twitch_url'] ?? ''); $logo_path = null; if (!filter_var($email, FILTER_VALIDATE_EMAIL)) { $_SESSION['flash'] = ['error' => 'Email invalide.']; header('Location: ' . $config['app']['base_url'] . '/?page=profile'); exit; } $stmt = $db->prepare('SELECT id FROM users WHERE email=? AND id!=?'); $stmt->execute([$email, current_user_id()]); if ($stmt->fetch()) { $_SESSION['flash'] = ['error' => 'Cet email est déjà utilisé.']; header('Location: ' . $config['app']['base_url'] . '/?page=profile'); exit; } if (!empty($_FILES['logo']['name'])) { $file = $_FILES['logo']; if ($file['error'] === UPLOAD_ERR_OK) { $allowed = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp']; $type = mime_content_type($file['tmp_name']); if (!isset($allowed[$type])) { $_SESSION['flash'] = ['error' => 'Format logo non supporté.']; header('Location: ' . $config['app']['base_url'] . '/?page=profile'); exit; } if ($file['size'] > 2 * 1024 * 1024) { $_SESSION['flash'] = ['error' => 'Logo trop lourd (max 2 Mo).']; header('Location: ' . $config['app']['base_url'] . '/?page=profile'); exit; } $ext = $allowed[$type]; $name = 'logo_' . current_user_id() . '_' . bin2hex(random_bytes(6)) . '.' . $ext; $destFs = __DIR__ . '/../public/uploads/' . $name; if (!move_uploaded_file($file['tmp_name'], $destFs)) { $_SESSION['flash'] = ['error' => 'Upload impossible.']; header('Location: ' . $config['app']['base_url'] . '/?page=profile'); exit; } $logo_path = $config['app']['base_url'] . '/uploads/' . $name; } } $fields = ['email' => $email, 'twitch_url' => ($twitch_url !== '' ? $twitch_url : null)]; $sql = 'UPDATE users SET email=:email, twitch_url=:twitch_url'; if ($logo_path !== null) { $sql .= ', logo_path=:logo_path'; $fields['logo_path'] = $logo_path; } if (strlen($password) > 0) { if (strlen($password) < 6) { $_SESSION['flash'] = ['error' => 'Mot de passe trop court.']; header('Location: ' . $config['app']['base_url'] . '/?page=profile'); exit; } $sql .= ', password_hash=:password_hash'; $fields['password_hash'] = password_hash($password, PASSWORD_DEFAULT); } $sql .= ' WHERE id=:id'; $fields['id'] = current_user_id(); $stmt = $db->prepare($sql); $stmt->execute($fields); $_SESSION['flash'] = ['success' => 'Profil mis à jour.']; header('Location: ' . $config['app']['base_url'] . '/?page=profile'); "@ WriteFile "actions/planning_create.php" @" <?php session_start(); require __DIR__ . '/../app/helpers/auth.php'; require __DIR__ . '/../app/helpers/weeks.php'; $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; if (!current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=login'); exit; } $title = trim($_POST['title'] ?? ''); $week_start = trim($_POST['week_start'] ?? ''); if ($title === '' || $week_start === '') { $_SESSION['flash'] = ['error' => 'Champs manquants.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $week_start = week_start_from_date($week_start); $stmt = $db->prepare('INSERT INTO plannings (user_id,title,week_start) VALUES (?,?,?)'); $stmt->execute([current_user_id(), $title, $week_start]); $_SESSION['flash'] = ['success' => 'Planning créé.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); "@ WriteFile "actions/planning_delete.php" @" <?php session_start(); require __DIR__ . '/../app/helpers/auth.php'; $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; if (!current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=login'); exit; } $id = (int)($_POST['id'] ?? 0); if ($id <= 0) { header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $stmt = $db->prepare('SELECT id,user_id FROM plannings WHERE id=?'); $stmt->execute([$id]); $p = $stmt->fetch(); if (!$p || (int)$p['user_id'] !== (int)current_user_id()) { $_SESSION['flash'] = ['error' => 'Action refusée.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $stmt = $db->prepare('DELETE FROM plannings WHERE id=?'); $stmt->execute([$id]); $_SESSION['flash'] = ['success' => 'Planning supprimé.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); "@ WriteFile "actions/planning_update.php" @" <?php session_start(); require __DIR__ . '/../app/helpers/auth.php'; require __DIR__ . '/../app/helpers/weeks.php'; $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; if (!current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=login'); exit; } $id = (int)($_POST['id'] ?? 0); $title = trim($_POST['title'] ?? ''); $week_start = trim($_POST['week_start'] ?? ''); if ($id <= 0 || $title === '' || $week_start === '') { $_SESSION['flash'] = ['error' => 'Champs manquants.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $stmt = $db->prepare('SELECT id,user_id FROM plannings WHERE id=?'); $stmt->execute([$id]); $p = $stmt->fetch(); if (!$p || (int)$p['user_id'] !== (int)current_user_id()) { $_SESSION['flash'] = ['error' => 'Action refusée.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $week_start = week_start_from_date($week_start); $stmt = $db->prepare('UPDATE plannings SET title=?, week_start=? WHERE id=?'); $stmt->execute([$title, $week_start, $id]); $_SESSION['flash'] = ['success' => 'Planning mis à jour.']; header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $id . '&week=' . $week_start); "@ WriteFile "actions/event_create.php" @" <?php session_start(); require __DIR__ . '/../app/helpers/auth.php'; $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; if (!current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=login'); exit; } $planning_id = (int)($_POST['planning_id'] ?? 0); $day_of_week = (int)($_POST['day_of_week'] ?? -1); $week = trim($_POST['week'] ?? ''); $game_name = trim($_POST['game_name'] ?? ''); $game_image_url = trim($_POST['game_image_url'] ?? ''); $stream_title = trim($_POST['stream_title'] ?? ''); $start_time = trim($_POST['start_time'] ?? ''); $end_time = trim($_POST['end_time'] ?? ''); if ($planning_id <= 0 || $day_of_week < 0 || $day_of_week > 6 || $game_name === '' || $start_time === '' || $end_time === '') { $_SESSION['flash'] = ['error' => 'Champs manquants.']; header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week); exit; } $stmt = $db->prepare('SELECT id,user_id FROM plannings WHERE id=?'); $stmt->execute([$planning_id]); $p = $stmt->fetch(); if (!$p || (int)$p['user_id'] !== (int)current_user_id()) { $_SESSION['flash'] = ['error' => 'Action refusée.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } if ($end_time <= $start_time) { $_SESSION['flash'] = ['error' => 'Heures invalides.']; header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week); exit; } $stmt = $db->prepare('INSERT INTO events (planning_id,game_name,game_image_url,stream_title,day_of_week,start_time,end_time) VALUES (?,?,?,?,?,?,?)'); $stmt->execute([ $planning_id, $game_name, ($game_image_url !== '' ? $game_image_url : null), ($stream_title !== '' ? $stream_title : null), $day_of_week, $start_time, $end_time ]); $_SESSION['flash'] = ['success' => 'Événement ajouté.']; header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week); "@ WriteFile "actions/event_update.php" @" <?php session_start(); require __DIR__ . '/../app/helpers/auth.php'; $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; if (!current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=login'); exit; } $id = (int)($_POST['id'] ?? 0); $planning_id = (int)($_POST['planning_id'] ?? 0); $week = trim($_POST['week'] ?? ''); $game_name = trim($_POST['game_name'] ?? ''); $game_image_url = trim($_POST['game_image_url'] ?? ''); $stream_title = trim($_POST['stream_title'] ?? ''); $start_time = trim($_POST['start_time'] ?? ''); $end_time = trim($_POST['end_time'] ?? ''); if ($id <= 0 || $planning_id <= 0 || $game_name === '' || $start_time === '' || $end_time === '') { $_SESSION['flash'] = ['error' => 'Champs manquants.']; header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week); exit; } $stmt = $db->prepare('SELECT e.id,p.user_id FROM events e JOIN plannings p ON p.id=e.planning_id WHERE e.id=?'); $stmt->execute([$id]); $row = $stmt->fetch(); if (!$row || (int)$row['user_id'] !== (int)current_user_id()) { $_SESSION['flash'] = ['error' => 'Action refusée.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } if ($end_time <= $start_time) { $_SESSION['flash'] = ['error' => 'Heures invalides.']; header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week); exit; } $stmt = $db->prepare('UPDATE events SET game_name=?, game_image_url=?, stream_title=?, start_time=?, end_time=? WHERE id=?'); $stmt->execute([ $game_name, ($game_image_url !== '' ? $game_image_url : null), ($stream_title !== '' ? $stream_title : null), $start_time, $end_time, $id ]); $_SESSION['flash'] = ['success' => 'Événement mis à jour.']; header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week); "@ WriteFile "actions/event_delete.php" @" <?php session_start(); require __DIR__ . '/../app/helpers/auth.php'; $config = require __DIR__ . '/../app/config/config.php'; $db = require __DIR__ . '/../app/config/db.php'; if (!current_user_id()) { header('Location: ' . $config['app']['base_url'] . '/?page=login'); exit; } $id = (int)($_POST['id'] ?? 0); $planning_id = (int)($_POST['planning_id'] ?? 0); $week = trim($_POST['week'] ?? ''); if ($id <= 0 || $planning_id <= 0) { header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $stmt = $db->prepare('SELECT e.id,p.user_id FROM events e JOIN plannings p ON p.id=e.planning_id WHERE e.id=?'); $stmt->execute([$id]); $row = $stmt->fetch(); if (!$row || (int)$row['user_id'] !== (int)current_user_id()) { $_SESSION['flash'] = ['error' => 'Action refusée.']; header('Location: ' . $config['app']['base_url'] . '/?page=plannings'); exit; } $stmt = $db->prepare('DELETE FROM events WHERE id=?'); $stmt->execute([$id]); $_SESSION['flash'] = ['success' => 'Événement supprimé.']; header('Location: ' . $config['app']['base_url'] . '/?page=planning&id=' . $planning_id . '&week=' . $week); "@ Write-Host "OK" ``` --- ###