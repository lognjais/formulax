/**
 * Altrusian Live Talent Telemetry & Candidate Scouting Dashboard HTML
 * Rendered at revision.altrusian.com/jai
 */

export const JAI_DASHBOARD_HTML = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Altrusian Watch: Live Talent & Ecosystem Telemetry</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>⚡</text></svg>">
  <style>
    :root {
      --bg: #05070a;
      --card-bg: rgba(255, 255, 255, 0.035);
      --card-border: rgba(255, 255, 255, 0.08);
      --ink: #e7ece9;
      --dim: #7f8a86;
      --gold: #e8a04a;
      --purple: #8a7ef7;
      --good: #5bb98c;
      --danger: #ef4444;
      --cyan: #38bdf8;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: radial-gradient(ellipse 80% 60% at 50% 0%, #121720 0%, #05070a 70%);
      color: var(--ink);
      font: 13px/1.45 ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      min-height: 100vh;
      padding: 20px;
    }

    /* Secret Door Screen */
    #door-screen {
      position: fixed;
      inset: 0;
      background: radial-gradient(ellipse 70% 50% at 50% 20%, #171d2b 0%, #040608 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 9999;
      padding: 20px;
      transition: opacity 0.35s ease, transform 0.35s ease;
    }
    #door-screen.unlocked {
      opacity: 0;
      pointer-events: none;
      transform: scale(1.04);
    }
    .door-box {
      max-width: 380px;
      width: 100%;
      background: rgba(18, 23, 34, 0.95);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      padding: 32px 28px;
      box-shadow: 0 20px 50px rgba(0,0,0,0.8), 0 0 40px rgba(232, 160, 74, 0.05);
      text-align: center;
    }
    .door-icon {
      font-size: 32px;
      margin-bottom: 12px;
      filter: drop-shadow(0 4px 12px rgba(232, 160, 74, 0.3));
    }
    .door-title {
      font: 700 18px system-ui, sans-serif;
      color: var(--ink);
      letter-spacing: -0.01em;
      margin-bottom: 6px;
    }
    .door-sub {
      font-size: 11px;
      color: var(--dim);
      margin-bottom: 22px;
      line-height: 1.4;
    }
    .door-input {
      width: 100%;
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid rgba(255, 255, 255, 0.12);
      border-radius: 8px;
      padding: 11px 14px;
      font: 14px monospace;
      color: #fff;
      text-align: center;
      margin-bottom: 14px;
      outline: none;
      transition: border-color 0.2s;
    }
    .door-input:focus {
      border-color: var(--gold);
      box-shadow: 0 0 10px rgba(232, 160, 74, 0.2);
    }
    .door-btn {
      width: 100%;
      background: linear-gradient(135deg, #e8a04a, #d97706);
      color: #05070a;
      border: none;
      border-radius: 8px;
      padding: 10px 16px;
      font: 700 13px system-ui, sans-serif;
      cursor: pointer;
      transition: transform 0.1s, opacity 0.2s;
    }
    .door-btn:active { transform: scale(0.98); }
    .door-error {
      color: var(--danger);
      font-size: 11px;
      margin-top: 10px;
      display: none;
    }

    /* Main Dashboard Layout */
    #dashboard { display: none; }
    #dashboard.visible { display: block; }

    header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 24px;
      padding-bottom: 16px;
      border-bottom: 1px solid var(--card-border);
      flex-wrap: wrap;
      gap: 12px;
    }
    .brand-title {
      font: 800 15px/1.2 system-ui, sans-serif;
      letter-spacing: 0.12em;
      text-transform: uppercase;
      color: var(--gold);
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .brand-sub {
      color: var(--dim);
      font-size: 11px;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      margin-top: 4px;
    }
    .header-actions {
      display: flex;
      align-items: center;
      gap: 10px;
      flex-wrap: wrap;
    }
    .endpoint-pill {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 6px 12px;
      background: rgba(255, 255, 255, 0.06);
      border: 1px solid var(--card-border);
      border-radius: 9999px;
      font-size: 11px;
      color: var(--ink);
    }
    .pulse-dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: var(--good);
      box-shadow: 0 0 8px var(--good);
      animation: pulse 2s infinite;
    }
    @keyframes pulse { 0%,100%{opacity:1;} 50%{opacity:0.3;} }

    .btn-action {
      background: rgba(255, 255, 255, 0.06);
      border: 1px solid var(--card-border);
      color: var(--ink);
      border-radius: 6px;
      padding: 6px 12px;
      font: 11px monospace;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      transition: background 0.15s;
    }
    .btn-action:hover { background: rgba(255, 255, 255, 0.12); }

    /* Metric Cards Grid */
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 12px;
      margin-bottom: 24px;
    }
    .card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 10px;
      padding: 14px 16px;
      position: relative;
    }
    .card-k {
      font-size: 10px;
      letter-spacing: 0.16em;
      text-transform: uppercase;
      color: var(--dim);
    }
    .card-v {
      font: 700 28px/1.1 system-ui, sans-serif;
      margin-top: 6px;
      color: var(--ink);
      font-variant-numeric: tabular-nums;
    }
    .card-sub {
      font-size: 11px;
      color: var(--dim);
      margin-top: 4px;
    }

    /* Tabs */
    .tabs {
      display: flex;
      gap: 8px;
      margin-bottom: 16px;
      border-bottom: 1px solid var(--card-border);
      padding-bottom: 10px;
      flex-wrap: wrap;
    }
    .tab {
      background: transparent;
      border: 1px solid var(--card-border);
      color: var(--dim);
      padding: 7px 16px;
      border-radius: 9999px;
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.06em;
      cursor: pointer;
      text-transform: uppercase;
      font-family: inherit;
      transition: all 0.15s;
    }
    .tab:hover { color: var(--ink); border-color: rgba(255,255,255,0.2); }
    .tab.active {
      background: rgba(232, 160, 74, 0.14);
      color: var(--gold);
      border-color: var(--gold);
    }

    .panel { display: none; }
    .panel.active { display: block; }

    /* Tables */
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 12px;
    }
    th {
      text-align: left;
      padding: 10px 12px;
      font-size: 10px;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      color: var(--dim);
      border-bottom: 1px solid var(--card-border);
    }
    td {
      padding: 10px 12px;
      border-bottom: 1px solid rgba(255, 255, 255, 0.04);
      vertical-align: middle;
    }
    tr:hover td { background: rgba(255, 255, 255, 0.02); }

    /* Badges */
    .badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 4px;
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 0.05em;
      text-transform: uppercase;
    }
    .badge-deep { background: rgba(138, 126, 247, 0.2); color: var(--purple); border: 1px solid rgba(138, 126, 247, 0.4); }
    .badge-method { background: rgba(56, 189, 248, 0.2); color: var(--cyan); border: 1px solid rgba(56, 189, 248, 0.4); }
    .badge-guess { background: rgba(239, 68, 68, 0.2); color: var(--danger); border: 1px solid rgba(239, 68, 68, 0.4); }
    .badge-churn { background: rgba(232, 160, 74, 0.2); color: var(--gold); border: 1px solid rgba(232, 160, 74, 0.4); }
    .badge-talent { background: rgba(91, 185, 140, 0.2); color: var(--good); border: 1px solid rgba(91, 185, 140, 0.4); }
    .badge-app { background: rgba(255, 255, 255, 0.08); color: var(--ink); border: 1px solid rgba(255,255,255,0.12); }

    .score-pill {
      font-weight: 800;
      font-size: 13px;
      color: var(--gold);
    }

    /* Candidate Roster Cards */
    .roster-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 16px;
    }
    .candidate-card {
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      border-radius: 12px;
      padding: 16px 18px;
      transition: border-color 0.2s, transform 0.2s;
    }
    .candidate-card:hover {
      border-color: rgba(232, 160, 74, 0.4);
      transform: translateY(-2px);
    }
    .candidate-head {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 12px;
    }
    .candidate-id {
      font: 700 13px system-ui, sans-serif;
      color: #fff;
    }
    .candidate-loc {
      font-size: 11px;
      color: var(--dim);
      margin-top: 2px;
    }
    .candidate-metrics {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px;
      margin: 12px 0;
      padding: 10px;
      background: rgba(0, 0, 0, 0.2);
      border-radius: 8px;
    }
    .cm-k { font-size: 10px; color: var(--dim); text-transform: uppercase; }
    .cm-v { font-weight: 700; color: var(--ink); margin-top: 2px; }

    /* Injector Modal */
    .modal-overlay {
      position: fixed;
      inset: 0;
      background: rgba(0,0,0,0.7);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
      z-index: 900;
    }
  </style>
</head>
<body>

  <!-- Secret Door Lock Screen -->
  <div id="door-screen">
    <div class="door-box">
      <div class="door-icon">🚪</div>
      <div class="door-title">Enter Access Key</div>
      <div class="door-sub">Altrusian live ecosystem telemetry, student talent scout, and analytics command center.</div>
      <input type="password" id="door-key" class="door-input" placeholder="Type key..." autofocus autocomplete="off" />
      <button id="door-btn" class="door-btn">Unlock Command Center</button>
      <div id="door-error" class="door-error">Incorrect key. Access denied.</div>
    </div>
  </div>

  <!-- Main Authenticated Dashboard -->
  <div id="dashboard">
    <header>
      <div>
        <div class="brand-title">
          <span>⚡ ALTRUSIAN / LIVE SCOUT & TELEMETRY</span>
        </div>
        <div class="brand-sub">Revision · Padhai · Pen Fight · QuestionX</div>
      </div>
      <div class="header-actions">
        <div class="endpoint-pill">
          <span class="pulse-dot"></span>
          <span id="sync-status">Edge KV Active</span>
        </div>
        <button id="refresh-btn" class="btn-action" title="Refresh Live Data">🔄 Refresh</button>
        <button id="export-btn" class="btn-action" title="Export Candidate Roster">📥 Export Roster</button>
        <button id="lock-btn" class="btn-action" title="Lock Dashboard">🔒 Lock</button>
      </div>
    </header>

    <!-- Top Overview Cards -->
    <div class="grid">
      <div class="card">
        <div class="card-k">Active Students</div>
        <div class="card-v" id="m-active">0</div>
        <div class="card-sub">Active in last 15 min</div>
      </div>
      <div class="card">
        <div class="card-k">Scouted Talent</div>
        <div class="card-v" style="color: var(--gold);" id="m-scouted">0</div>
        <div class="card-sub">High cognitive score &gt;= 78</div>
      </div>
      <div class="card">
        <div class="card-k">Deep Thinker Ratio</div>
        <div class="card-v" style="color: var(--purple);" id="m-ratio">0%</div>
        <div class="card-sub">Methodical solvers vs guessers</div>
      </div>
      <div class="card">
        <div class="card-k">Questions Attempted</div>
        <div class="card-v" id="m-questions">0</div>
        <div class="card-sub">Real practice sessions</div>
      </div>
      <div class="card">
        <div class="card-k">Derivations Explored</div>
        <div class="card-v" style="color: var(--cyan);" id="m-derivations">0</div>
        <div class="card-sub">Deep formula proofs read</div>
      </div>
      <div class="card">
        <div class="card-k">Total Tracked</div>
        <div class="card-v" id="m-total">0</div>
        <div class="card-sub">Ecosystem learners</div>
      </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="tabs">
      <button class="tab active" data-tab="tab-feed">Live Event Stream</button>
      <button class="tab" data-tab="tab-roster">Scouted Candidates (Talent)</button>
      <button class="tab" data-tab="tab-students">Student Registry</button>
      <button class="tab" data-tab="tab-archetypes">Archetype Matrix</button>
    </div>

    <!-- Tab 1: Live Event Stream -->
    <div id="tab-feed" class="panel active">
      <div class="card" style="padding: 0; overflow-x: auto;">
        <table>
          <thead>
            <tr>
              <th>Time</th>
              <th>App</th>
              <th>Student ID</th>
              <th>Location</th>
              <th>Event</th>
              <th>Cognitive Archetype</th>
              <th>Details</th>
            </tr>
          </thead>
          <tbody id="feed-tbody">
            <tr><td colspan="7" style="text-align: center; color: var(--dim); padding: 24px;">Listening for live events...</td></tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Tab 2: Scouted Candidates -->
    <div id="tab-roster" class="panel">
      <div class="roster-grid" id="roster-container">
        <div style="color: var(--dim); padding: 20px;">No candidates scouted yet. High-performing students appear automatically.</div>
      </div>
    </div>

    <!-- Tab 3: Student Registry -->
    <div id="tab-students" class="panel">
      <div class="card" style="padding: 0; overflow-x: auto;">
        <table>
          <thead>
            <tr>
              <th>Student ID</th>
              <th>App</th>
              <th>Location</th>
              <th>Archetype</th>
              <th>Scout Score</th>
              <th>Accuracy</th>
              <th>Avg Dwell</th>
              <th>Derivations</th>
              <th>Last Seen</th>
            </tr>
          </thead>
          <tbody id="students-tbody">
            <tr><td colspan="9" style="text-align: center; color: var(--dim); padding: 24px;">No student records found.</td></tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Tab 4: Archetype Matrix -->
    <div id="tab-archetypes" class="panel">
      <div class="card" style="padding: 20px;">
        <h3 style="font-size: 14px; margin-bottom: 12px; color: var(--gold);">Cognitive Archetypes for Talent Acquisition</h3>
        <p style="color: var(--dim); margin-bottom: 20px; line-height: 1.6;">
          Our proprietary telemetry measures genuine problem-solving depth over mechanical rote work:
        </p>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px;">
          <div style="background: rgba(138, 126, 247, 0.08); border: 1px solid rgba(138, 126, 247, 0.3); border-radius: 8px; padding: 14px;">
            <div style="font-weight: 700; color: var(--purple); margin-bottom: 4px;">🧠 Deep Thinker</div>
            <div style="font-size: 11px; color: var(--dim); line-height: 1.5;">High accuracy (80%+), deliberate dwell times (35 to 120 seconds per question), and actively explores formula derivations. Prime candidate for systems engineering and research roles.</div>
          </div>
          <div style="background: rgba(56, 189, 248, 0.08); border: 1px solid rgba(56, 189, 248, 0.3); border-radius: 8px; padding: 14px;">
            <div style="font-weight: 700; color: var(--cyan); margin-bottom: 4px;">📐 Methodical Solver</div>
            <div style="font-size: 11px; color: var(--dim); line-height: 1.5;">Solid accuracy (70%+), consistent pacing (25 to 60s dwell), steady streak progression. Reliable, disciplined executor.</div>
          </div>
          <div style="background: rgba(232, 160, 74, 0.08); border: 1px solid rgba(232, 160, 74, 0.3); border-radius: 8px; padding: 14px;">
            <div style="font-weight: 700; color: var(--gold); margin-bottom: 4px;">⚡ Rote Churner</div>
            <div style="font-size: 11px; color: var(--dim); line-height: 1.5;">Attempts high question volumes with sub-20s dwell and inconsistent accuracy. Relies on memory rather than derivation logic.</div>
          </div>
          <div style="background: rgba(239, 68, 68, 0.08); border: 1px solid rgba(239, 68, 68, 0.3); border-radius: 8px; padding: 14px;">
            <div style="font-weight: 700; color: var(--danger); margin-bottom: 4px;">🎲 Quick Guesser</div>
            <div style="font-size: 11px; color: var(--dim); line-height: 1.5;">Sub-10s answer speeds with low accuracy. Rapid option clicking without calculation or conceptual engagement.</div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    // Secret Door Access Logic
    const doorScreen = document.getElementById('door-screen');
    const dashboard = document.getElementById('dashboard');
    const doorKeyInput = document.getElementById('door-key');
    const doorBtn = document.getElementById('door-btn');
    const doorError = document.getElementById('door-error');
    const lockBtn = document.getElementById('lock-btn');

    function checkAuth() {
      const savedKey = localStorage.getItem('jai_access_key');
      if (savedKey === 'jai' || savedKey === 'Jai' || savedKey === 'JAI') {
        unlockDoor();
      }
    }

    function unlockDoor() {
      doorScreen.classList.add('unlocked');
      setTimeout(() => {
        doorScreen.style.display = 'none';
        dashboard.classList.add('visible');
        fetchData();
        startAutoRefresh();
      }, 350);
    }

    function attemptUnlock() {
      const key = (doorKeyInput.value || '').trim();
      if (key.toLowerCase() === 'jai') {
        localStorage.setItem('jai_access_key', 'jai');
        doorError.style.display = 'none';
        unlockDoor();
      } else {
        doorError.style.display = 'block';
        doorKeyInput.value = '';
        doorKeyInput.focus();
      }
    }

    doorBtn.addEventListener('click', attemptUnlock);
    doorKeyInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') attemptUnlock();
    });

    lockBtn.addEventListener('click', () => {
      localStorage.removeItem('jai_access_key');
      window.location.reload();
    });

    checkAuth();

    // Tab Navigation
    document.querySelectorAll('.tab').forEach((tab) => {
      tab.addEventListener('click', () => {
        document.querySelectorAll('.tab').forEach((t) => t.classList.remove('active'));
        document.querySelectorAll('.panel').forEach((p) => p.classList.remove('active'));
        tab.classList.add('active');
        const target = document.getElementById(tab.getAttribute('data-tab'));
        if (target) target.classList.add('active');
      });
    });

    // Data Fetching & Rendering
    let cachedCandidates = [];

    async function fetchData() {
      try {
        const res = await fetch('/api/jai/feed');
        if (!res.ok) return;
        const data = await res.json();
        renderSummary(data.summary || {});
        renderEvents(data.events || []);
        renderCandidates(data.candidates || []);
        renderStudents(data.students || []);
        cachedCandidates = data.candidates || [];
      } catch (err) {
        console.error('Failed to fetch telemetry feed:', err);
      }
    }

    function renderSummary(s) {
      document.getElementById('m-active').textContent = s.active_students || 0;
      document.getElementById('m-scouted').textContent = s.scouted_candidates || 0;
      document.getElementById('m-ratio').textContent = (s.studious_ratio || 0) + '%';
      document.getElementById('m-questions').textContent = s.total_questions || 0;
      document.getElementById('m-derivations').textContent = s.total_derivations || 0;
      document.getElementById('m-total').textContent = s.total_students_tracked || 0;
    }

    function renderEvents(events) {
      const tbody = document.getElementById('feed-tbody');
      if (!events || events.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--dim); padding: 24px;">No telemetry events logged yet.</td></tr>';
        return;
      }
      tbody.innerHTML = events.map((ev) => {
        const time = new Date(ev.timestamp || Date.now()).toLocaleTimeString();
        const archClass = ev.archetype === 'Deep Thinker' ? 'badge-deep' : (ev.archetype === 'Methodical Solver' ? 'badge-method' : (ev.archetype === 'Quick Guesser' ? 'badge-guess' : 'badge-churn'));
        const props = ev.properties || {};
        let details = '';
        if (ev.event === 'question_answered') {
          details = (props.subject || '') + ' ' + (props.chapter || '') + ' · dwell: ' + (props.dwell_seconds || 0) + 's · correct: ' + (props.is_correct ? '✅' : '❌');
        } else if (ev.event === 'derivation_expanded') {
          details = 'Proof: ' + (props.formula_title || props.formula_id || 'Derivation expanded');
        } else if (ev.event === 'quiz_completed') {
          details = 'Score: ' + (props.score || 0) + ' (' + (props.correct || 0) + '/' + (props.answered || 0) + ') · acc: ' + (props.accuracy_percent || 0) + '%';
        } else {
          details = JSON.stringify(props).slice(0, 50);
        }

        return '<tr>' +
          '<td style="color: var(--dim);">' + time + '</td>' +
          '<td><span class="badge badge-app">' + (ev.app || 'padhai') + '</span></td>' +
          '<td style="font-weight: 700; color: var(--ink);">' + (ev.student_id || 'anon') + '</td>' +
          '<td style="color: var(--dim);">' + (ev.location || 'Unknown') + '</td>' +
          '<td><span style="color: var(--cyan);">' + (ev.event || '') + '</span></td>' +
          '<td><span class="badge ' + archClass + '">' + (ev.archetype || 'Explorer') + '</span></td>' +
          '<td style="font-size: 11px; color: var(--dim);">' + details + '</td>' +
        '</tr>';
      }).join('');
    }

    function renderCandidates(candidates) {
      const container = document.getElementById('roster-container');
      if (!candidates || candidates.length === 0) {
        container.innerHTML = '<div style="color: var(--dim); padding: 20px;">No candidates scouted yet. High-performing students appear automatically.</div>';
        return;
      }
      container.innerHTML = candidates.map((c) => {
        const accuracy = c.questions_attempted > 0 ? Math.round((c.correct_answers / c.questions_attempted) * 100) : 0;
        return '<div class="candidate-card">' +
          '<div class="candidate-head">' +
            '<div>' +
              '<div class="candidate-id">' + c.student_id + '</div>' +
              '<div class="candidate-loc">📍 ' + (c.location || 'India') + ' · App: ' + (c.app || 'Padhai') + '</div>' +
            '</div>' +
            '<div class="score-pill">' + (c.scout_score || 0) + '/100</div>' +
          '</div>' +
          '<div><span class="badge badge-talent">' + (c.candidate_status || 'Top Talent') + '</span> <span class="badge badge-deep" style="margin-left: 4px;">' + (c.archetype || 'Deep Thinker') + '</span></div>' +
          '<div class="candidate-metrics">' +
            '<div><div class="cm-k">Accuracy</div><div class="cm-v">' + accuracy + '% (' + (c.correct_answers || 0) + '/' + (c.questions_attempted || 0) + ')</div></div>' +
            '<div><div class="cm-k">Avg Dwell</div><div class="cm-v">' + (c.avg_dwell_seconds || 0) + 's / Q</div></div>' +
            '<div><div class="cm-k">Derivations</div><div class="cm-v">' + (c.derivations_viewed || 0) + ' read</div></div>' +
            '<div><div class="cm-k">Best Streak</div><div class="cm-v">🔥 ' + (c.best_streak || 0) + '</div></div>' +
          '</div>' +
          '<div style="font-size: 11px; color: var(--dim); line-height: 1.45;">' + (c.notes || 'Thorough derivation reader with consistent question solving dwell time.') + '</div>' +
        '</div>';
      }).join('');
    }

    function renderStudents(students) {
      const tbody = document.getElementById('students-tbody');
      if (!students || students.length === 0) {
        tbody.innerHTML = '<tr><td colspan="9" style="text-align: center; color: var(--dim); padding: 24px;">No student records found.</td></tr>';
        return;
      }
      tbody.innerHTML = students.map((s) => {
        const accuracy = s.questions_attempted > 0 ? Math.round((s.correct_answers / s.questions_attempted) * 100) : 0;
        const time = new Date(s.last_seen || Date.now()).toLocaleTimeString();
        return '<tr>' +
          '<td style="font-weight: 700; color: #fff;">' + s.student_id + '</td>' +
          '<td><span class="badge badge-app">' + (s.app || 'padhai') + '</span></td>' +
          '<td style="color: var(--dim);">' + (s.location || 'Unknown') + '</td>' +
          '<td><span class="badge badge-deep">' + (s.archetype || 'Explorer') + '</span></td>' +
          '<td style="font-weight: 700; color: var(--gold);">' + (s.scout_score || 0) + '</td>' +
          '<td>' + accuracy + '%</td>' +
          '<td>' + (s.avg_dwell_seconds || 0) + 's</td>' +
          '<td>' + (s.derivations_viewed || 0) + '</td>' +
          '<td style="color: var(--dim);">' + time + '</td>' +
        '</tr>';
      }).join('');
    }

    // Export Roster JSON
    document.getElementById('export-btn').addEventListener('click', () => {
      const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(cachedCandidates, null, 2));
      const downloadAnchor = document.createElement('a');
      downloadAnchor.setAttribute("href", dataStr);
      downloadAnchor.setAttribute("download", "scouted_candidates_" + new Date().toISOString().slice(0, 10) + ".json");
      document.body.appendChild(downloadAnchor);
      downloadAnchor.click();
      downloadAnchor.remove();
    });

    document.getElementById('refresh-btn').addEventListener('click', fetchData);

    let refreshInterval = null;
    function startAutoRefresh() {
      if (refreshInterval) clearInterval(refreshInterval);
      refreshInterval = setInterval(fetchData, 5000);
    }
  </script>
</body>
</html>
`;
