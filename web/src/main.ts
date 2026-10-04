import "./styles/app.css";
import katex from "katex";

interface RelatedConcept {
  name: string;
  definition: string;
}

interface FormulaRecord {
  id: string;
  subject: string;
  topic: string;
  title: string;
  visual_type?: string;
  visual_data: string;
  description: string;
  derivation?: string;
  related_concepts?: RelatedConcept[];
}

interface SubjectMeta {
  id: string;
  name: string;
  count: number;
  topics: string[];
  file: string;
}

interface Manifest {
  version: string;
  total_formulas: number;
  subjects: SubjectMeta[];
}

class SutraApp {
  private appContainer: HTMLElement;
  private manifest: Manifest | null = null;
  private currentSubject: string = "physics";
  private currentTopic: string = "All";
  private searchQuery: string = "";
  private formulasCache: Map<string, FormulaRecord[]> = new Map();
  private currentFormulas: FormulaRecord[] = [];

  constructor() {
    this.appContainer = document.getElementById("app") as HTMLElement;
    this.initTheme();
    this.initServiceWorker();
    this.initApp();
  }

  private initTheme() {
    const root = document.documentElement;
    const themeBtn = document.getElementById("theme-toggle");
    const themeIcon = document.getElementById("theme-icon");

    const savedTheme = localStorage.getItem("revision_theme");
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    const isDark = savedTheme ? savedTheme === "dark" : prefersDark;

    root.classList.toggle("dark", isDark);
    root.classList.toggle("light", !isDark);
    if (themeIcon) themeIcon.textContent = isDark ? "☀️" : "🌙";

    themeBtn?.addEventListener("click", () => {
      const willBeDark = !root.classList.contains("dark");
      root.classList.toggle("dark", willBeDark);
      root.classList.toggle("light", !willBeDark);
      localStorage.setItem("revision_theme", willBeDark ? "dark" : "light");
      if (themeIcon) themeIcon.textContent = willBeDark ? "☀️" : "🌙";
    });
  }

  private initServiceWorker() {
    if ("serviceWorker" in navigator) {
      window.addEventListener("load", () => {
        navigator.serviceWorker.register("./sw.js").catch(() => {});
      });
    }
  }

  private async initApp() {
    this.renderLoading();
    try {
      const res = await fetch("data/manifest.json");
      if (res.ok) {
        this.manifest = await res.json();
      }
    } catch {}

    await this.loadSubject(this.currentSubject);
  }

  private renderLoading() {
    this.appContainer.innerHTML = `
      <div style="display: flex; justify-content: center; align-items: center; min-height: 400px;">
        <div style="text-align: center;">
          <div style="font-size: 2.2rem; margin-bottom: 1rem;">⚡</div>
          <div style="font-size: 1.1rem; font-weight: 700; color: var(--ink-max);">Loading Formula Bank...</div>
        </div>
      </div>
    `;
  }

  private async loadSubject(subjectId: string) {
    this.currentSubject = subjectId;
    this.currentTopic = "All";
    this.searchQuery = "";

    if (this.formulasCache.has(subjectId)) {
      this.currentFormulas = this.formulasCache.get(subjectId)!;
      this.render();
      return;
    }

    this.renderLoading();

    try {
      const res = await fetch(`data/${subjectId}.json`);
      if (!res.ok) throw new Error("Failed to load subject data");
      const data: FormulaRecord[] = await res.json();
      this.formulasCache.set(subjectId, data);
      this.currentFormulas = data;
      this.render();
    } catch (err) {
      this.appContainer.innerHTML = `
        <div style="text-align: center; padding: 3rem 1rem;">
          <p style="color: var(--danger-9); font-weight: 700;">Failed to load formulas. Please try again.</p>
          <button class="qx-header-link" id="retry-btn">Retry</button>
        </div>
      `;
      document.getElementById("retry-btn")?.addEventListener("click", () => this.loadSubject(subjectId));
    }
  }

  private renderMathInText(text: string): string {
    if (!text) return "";
    // Replace \( ... \) with KaTeX inline
    return text.replace(/\\\((.*?)\\\)/g, (_, latex) => {
      try {
        return katex.renderToString(latex, { displayMode: false, throwOnError: false });
      } catch {
        return latex;
      }
    });
  }

  private render() {
    const subjects = this.manifest?.subjects || [
      { id: "physics", name: "Physics", count: 0, topics: [], file: "physics.json" },
      { id: "chemistry", name: "Chemistry", count: 0, topics: [], file: "chemistry.json" },
      { id: "math", name: "Mathematics", count: 0, topics: [], file: "math.json" },
      { id: "biology", name: "Biology", count: 0, topics: [], file: "biology.json" },
    ];

    // Subject tabs
    const subjectTabsHtml = subjects
      .map(
        (s) => `
        <button class="sutra-subject-btn ${s.id === this.currentSubject ? "active" : ""}" data-subject="${s.id}">
          <span>${s.id === "physics" ? "⚡" : s.id === "chemistry" ? "🧪" : s.id === "math" ? "📐" : "🧬"}</span>
          <span>${s.name}</span>
        </button>
      `
      )
      .join("");

    // Topics list with counts
    const topicCounts = new Map<string, number>();
    for (const f of this.currentFormulas) {
      const t = f.topic || "General";
      topicCounts.set(t, (topicCounts.get(t) || 0) + 1);
    }
    const topics = Array.from(topicCounts.keys()).sort();

    const topicItemsHtml = [
      `
      <div class="sutra-topic-item ${this.currentTopic === "All" ? "active" : ""}" data-topic="All">
        <span>All Topics</span>
        <span class="sutra-topic-count">${this.currentFormulas.length}</span>
      </div>
    `,
      ...topics.map(
        (t) => `
      <div class="sutra-topic-item ${this.currentTopic === t ? "active" : ""}" data-topic="${t}">
        <span style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 170px;">${t}</span>
        <span class="sutra-topic-count">${topicCounts.get(t)}</span>
      </div>
    `
      ),
    ].join("");

    // Filter formulas
    let filtered = this.currentFormulas;
    if (this.currentTopic !== "All") {
      filtered = filtered.filter((f) => f.topic === this.currentTopic);
    }
    if (this.searchQuery.trim()) {
      const q = this.searchQuery.toLowerCase().trim();
      filtered = filtered.filter(
        (f) =>
          f.title.toLowerCase().includes(q) ||
          f.description.toLowerCase().includes(q) ||
          (f.visual_data && f.visual_data.toLowerCase().includes(q)) ||
          (f.topic && f.topic.toLowerCase().includes(q))
      );
    }

    // Formula cards
    const formulaCardsHtml =
      filtered.length === 0
        ? `
      <div class="glass-card" style="padding: 3rem 1rem; text-align: center; color: var(--neutral-10);">
        <p style="font-size: 1.1rem; font-weight: 700;">No formulas found matching "${this.searchQuery}"</p>
        <p style="font-size: 0.85rem;">Try a different keyword or select another topic.</p>
      </div>
    `
        : filtered
            .map((f) => {
              let renderedMath = "";
              try {
                renderedMath = katex.renderToString(f.visual_data || "", {
                  displayMode: true,
                  throwOnError: false,
                });
              } catch {
                renderedMath = `<code>${f.visual_data}</code>`;
              }

              const formattedDesc = this.renderMathInText(f.description);

              const conceptsHtml =
                f.related_concepts && f.related_concepts.length > 0
                  ? `
                <div class="formula-concepts">
                  ${f.related_concepts
                    .map(
                      (c) => `
                    <span class="formula-concept-pill" title="${c.definition || ""}">
                      📌 ${c.name}
                    </span>
                  `
                    )
                    .join("")}
                </div>
              `
                  : "";

              const derivationHtml = f.derivation
                ? `
                <div class="formula-derivation">
                  <div class="formula-derivation-toggle" data-formula-id="${f.id}">
                    <span>▶ Show Derivation</span>
                  </div>
                  <div class="formula-derivation-content" id="derivation-${f.id}" style="display: none;">
                    ${this.renderMathInText(f.derivation)}
                  </div>
                </div>
              `
                : "";

              return `
            <div class="glass-card formula-card" id="card-${f.id}">
              <div class="formula-header">
                <span class="formula-topic-badge">${f.topic}</span>
                <div class="formula-actions">
                  <button class="formula-btn-icon copy-latex-btn" data-latex="${encodeURIComponent(f.visual_data)}" title="Copy LaTeX">
                    📋 Copy LaTeX
                  </button>
                </div>
              </div>

              <div class="formula-title">${f.title}</div>
              
              <div class="formula-math-box">
                ${renderedMath}
              </div>

              <div class="formula-description">
                ${formattedDesc}
              </div>

              ${conceptsHtml}
              ${derivationHtml}
            </div>
          `;
            })
            .join("");

    this.appContainer.innerHTML = `
      <div class="sutra-hero">
        <h1>Revision: <span>Formula Bank</span></h1>
        <p>Instant formulas, step-by-step derivations, and key concepts for NEET & JEE. Fast, clean, and offline-ready.</p>

        <div class="sutra-search-box">
          <svg class="sutra-search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"></circle>
            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
          <input type="text" class="sutra-search-input" id="search-input" placeholder="Search 3,500+ formulas, variables, topics..." value="${this.searchQuery}" />
        </div>

        <div class="sutra-subjects">
          ${subjectTabsHtml}
        </div>
      </div>

      <div class="sutra-layout">
        <aside class="glass-card sutra-sidebar">
          <div class="sutra-sidebar-title">Topics & Chapters</div>
          <div class="sutra-topic-list">
            ${topicItemsHtml}
          </div>
        </aside>

        <section class="formula-grid">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; font-size: 0.85rem; color: var(--neutral-11);">
            <span>Showing <strong>${filtered.length}</strong> formulas in <strong>${this.currentTopic === "All" ? "All Topics" : this.currentTopic}</strong></span>
            ${this.searchQuery ? `<button id="clear-search" style="background: none; border: none; color: var(--tulip-bloom-10); cursor: pointer; font-weight: 700;">Clear search ✕</button>` : ""}
          </div>
          ${formulaCardsHtml}
        </section>
      </div>
    `;

    this.bindEvents();
  }

  private bindEvents() {
    // Subject tab switching
    this.appContainer.querySelectorAll("[data-subject]").forEach((btn) => {
      btn.addEventListener("click", (e) => {
        const sub = (e.currentTarget as HTMLElement).getAttribute("data-subject");
        if (sub && sub !== this.currentSubject) {
          this.loadSubject(sub);
        }
      });
    });

    // Topic selection
    this.appContainer.querySelectorAll("[data-topic]").forEach((el) => {
      el.addEventListener("click", (e) => {
        const topic = (e.currentTarget as HTMLElement).getAttribute("data-topic");
        if (topic) {
          this.currentTopic = topic;
          this.render();
          window.scrollTo({ top: 380, behavior: "smooth" });
        }
      });
    });

    // Search input
    const searchInput = document.getElementById("search-input") as HTMLInputElement;
    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        this.searchQuery = (e.target as HTMLInputElement).value;
        this.renderFormulaGridOnly();
      });
    }

    document.getElementById("clear-search")?.addEventListener("click", () => {
      this.searchQuery = "";
      this.render();
    });

    // Derivation expand/collapse
    this.appContainer.querySelectorAll(".formula-derivation-toggle").forEach((toggle) => {
      toggle.addEventListener("click", (e) => {
        const target = e.currentTarget as HTMLElement;
        const id = target.getAttribute("data-formula-id");
        const content = document.getElementById(`derivation-${id}`);
        if (content) {
          const isHidden = content.style.display === "none";
          content.style.display = isHidden ? "block" : "none";
          target.innerHTML = isHidden ? "▼ Hide Derivation" : "▶ Show Derivation";
        }
      });
    });

    // Copy LaTeX
    this.appContainer.querySelectorAll(".copy-latex-btn").forEach((btn) => {
      btn.addEventListener("click", async (e) => {
        const target = e.currentTarget as HTMLElement;
        const latex = decodeURIComponent(target.getAttribute("data-latex") || "");
        try {
          await navigator.clipboard.writeText(latex);
          const orig = target.innerHTML;
          target.innerHTML = "✓ Copied!";
          setTimeout(() => {
            target.innerHTML = orig;
          }, 1800);
        } catch {}
      });
    });
  }

  private renderFormulaGridOnly() {
    // Re-render when searching without destroying the input element
    let filtered = this.currentFormulas;
    if (this.currentTopic !== "All") {
      filtered = filtered.filter((f) => f.topic === this.currentTopic);
    }
    if (this.searchQuery.trim()) {
      const q = this.searchQuery.toLowerCase().trim();
      filtered = filtered.filter(
        (f) =>
          f.title.toLowerCase().includes(q) ||
          f.description.toLowerCase().includes(q) ||
          (f.visual_data && f.visual_data.toLowerCase().includes(q)) ||
          (f.topic && f.topic.toLowerCase().includes(q))
      );
    }

    const grid = this.appContainer.querySelector(".formula-grid");
    if (!grid) {
      this.render();
      return;
    }

    const cardsHtml =
      filtered.length === 0
        ? `
      <div class="glass-card" style="padding: 3rem 1rem; text-align: center; color: var(--neutral-10);">
        <p style="font-size: 1.1rem; font-weight: 700;">No formulas found matching "${this.searchQuery}"</p>
        <p style="font-size: 0.85rem;">Try a different keyword or select another topic.</p>
      </div>
    `
        : filtered
            .map((f) => {
              let renderedMath = "";
              try {
                renderedMath = katex.renderToString(f.visual_data || "", {
                  displayMode: true,
                  throwOnError: false,
                });
              } catch {
                renderedMath = `<code>${f.visual_data}</code>`;
              }

              const formattedDesc = this.renderMathInText(f.description);

              const derivationHtml = f.derivation
                ? `
                <div class="formula-derivation">
                  <div class="formula-derivation-toggle" data-formula-id="${f.id}">
                    <span>▶ Show Derivation</span>
                  </div>
                  <div class="formula-derivation-content" id="derivation-${f.id}" style="display: none;">
                    ${this.renderMathInText(f.derivation)}
                  </div>
                </div>
              `
                : "";

              return `
            <div class="glass-card formula-card" id="card-${f.id}">
              <div class="formula-header">
                <span class="formula-topic-badge">${f.topic}</span>
                <div class="formula-actions">
                  <button class="formula-btn-icon copy-latex-btn" data-latex="${encodeURIComponent(f.visual_data)}" title="Copy LaTeX">
                    📋 Copy LaTeX
                  </button>
                </div>
              </div>

              <div class="formula-title">${f.title}</div>
              
              <div class="formula-math-box">
                ${renderedMath}
              </div>

              <div class="formula-description">
                ${formattedDesc}
              </div>

              ${derivationHtml}
            </div>
          `;
            })
            .join("");

    grid.innerHTML = `
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; font-size: 0.85rem; color: var(--neutral-11);">
        <span>Showing <strong>${filtered.length}</strong> formulas in <strong>${this.currentTopic === "All" ? "All Topics" : this.currentTopic}</strong></span>
        ${this.searchQuery ? `<button id="clear-search" style="background: none; border: none; color: var(--tulip-bloom-10); cursor: pointer; font-weight: 700;">Clear search ✕</button>` : ""}
      </div>
      ${cardsHtml}
    `;

    document.getElementById("clear-search")?.addEventListener("click", () => {
      this.searchQuery = "";
      const input = document.getElementById("search-input") as HTMLInputElement;
      if (input) input.value = "";
      this.renderFormulaGridOnly();
    });

    // Rebind derivations and copy buttons
    grid.querySelectorAll(".formula-derivation-toggle").forEach((toggle) => {
      toggle.addEventListener("click", (e) => {
        const target = e.currentTarget as HTMLElement;
        const id = target.getAttribute("data-formula-id");
        const content = document.getElementById(`derivation-${id}`);
        if (content) {
          const isHidden = content.style.display === "none";
          content.style.display = isHidden ? "block" : "none";
          target.innerHTML = isHidden ? "▼ Hide Derivation" : "▶ Show Derivation";
        }
      });
    });

    grid.querySelectorAll(".copy-latex-btn").forEach((btn) => {
      btn.addEventListener("click", async (e) => {
        const target = e.currentTarget as HTMLElement;
        const latex = decodeURIComponent(target.getAttribute("data-latex") || "");
        try {
          await navigator.clipboard.writeText(latex);
          const orig = target.innerHTML;
          target.innerHTML = "✓ Copied!";
          setTimeout(() => {
            target.innerHTML = orig;
          }, 1800);
        } catch {}
      });
    });
  }
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => new SutraApp());
} else {
  new SutraApp();
}
