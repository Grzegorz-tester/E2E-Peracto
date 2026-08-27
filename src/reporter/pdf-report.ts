import dotenv from 'dotenv'
import fs from 'fs'
import path from 'path'
import os from 'os'
import { execSync } from 'child_process'
import { chromium } from 'playwright'
import { env } from '../env/parseEnv'

dotenv.config({path: env('COMMON_CONFIG_FILE', 'env/common.env')})

type CucumberStepResult = { status?: string; duration?: number; error_message?: string }
type CucumberTag = { name: string }
type CucumberStep = { keyword: string; name?: string; hidden?: boolean; result?: CucumberStepResult }
type CucumberElement = { name: string; keyword: string; tags?: CucumberTag[]; steps?: CucumberStep[] }
type CucumberFeature = { name: string; uri?: string; elements?: CucumberElement[] }

type Status = 'passed' | 'failed' | 'skipped'

const scenarioStatus = (element: CucumberElement): Status => {
    const statuses = (element.steps ?? []).map(step => step.result?.status)
    if (statuses.includes('failed')) return 'failed'
    if (statuses.length > 0 && statuses.every(status => status === 'passed')) return 'passed'
    return 'skipped'
}

// Cucumber step results can also be 'pending' / 'undefined' / 'ambiguous' -
// none of those are "failed", so bucket them with 'skipped' for colouring
// while still showing their real (capitalised) status text in the table.
const normalizeStatus = (raw?: string): Status => {
    if (raw === 'passed') return 'passed'
    if (raw === 'failed') return 'failed'
    return 'skipped'
}

const displayStatusLabel = (raw?: string): string => {
    const status = raw ?? 'skipped'
    return status.charAt(0).toUpperCase() + status.slice(1)
}

const escapeHtml = (value: string) =>
    value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

const STATUS_COLOR: Record<Status, string> = {
    passed: '#00875A',
    failed: '#DE350B',
    skipped: '#6B7785',
}

const formatDuration = (nanoseconds?: number): string => {
    if (!nanoseconds) return ''
    const ms = nanoseconds / 1_000_000
    if (ms < 1000) return `${Math.round(ms)}ms`
    return `${(ms / 1000).toFixed(1)}s`
}

// HH:MM:SS.mmm - used for the run-level and scenario-level "time spent"
// figures, which want the same clock-style formatting throughout.
const formatClock = (nanoseconds = 0): string => {
    const totalMs = Math.round(nanoseconds / 1_000_000)
    const totalSeconds = Math.floor(totalMs / 1000)
    const millis = totalMs % 1000
    const hours = Math.floor(totalSeconds / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60
    const pad2 = (n: number) => String(n).padStart(2, '0')
    const pad3 = (n: number) => String(n).padStart(3, '0')
    return `${pad2(hours)}:${pad2(minutes)}:${pad2(seconds)}.${pad3(millis)}`
}

const formatTimestamp = (date: Date): string => {
    const pad = (n: number) => String(n).padStart(2, '0')
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}

// Filename-safe variant - colons aren't valid in Windows filenames and are
// awkward on macOS, so the file itself uses hyphens while the in-document
// title keeps the more readable colon-separated formatTimestamp() above.
const formatTimestampForFilename = (date: Date): string => {
    const pad = (n: number) => String(n).padStart(2, '0')
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}_${pad(date.getHours())}-${pad(date.getMinutes())}-${pad(date.getSeconds())}`
}

// Who ran this: prefer git's configured user (matches how the rest of the
// suite attributes checkout test data, e.g. "Velstar Test" notes) and fall
// back to the OS account if git isn't configured in this environment.
const getRunner = (): string => {
    try {
        const name = execSync('git config user.name', {encoding: 'utf-8'}).trim()
        if (name) return name
    } catch {
        // git not available / no user.name set - fall through
    }
    try {
        return os.userInfo().username
    } catch {
        return '-'
    }
}

const sumDurations = (element: CucumberElement): number =>
    (element.steps ?? []).reduce((sum, step) => sum + (step.result?.duration ?? 0), 0)

const renderStepRow = (step: CucumberStep, index: number): string => {
    const rawStatus = step.result?.status
    const status = normalizeStatus(rawStatus)
    const keyword = (step.keyword ?? '').trim()
    const text = escapeHtml(step.name ?? '')
    const duration = formatDuration(step.result?.duration)
    const comment = step.result?.error_message
        ? `<div class="step-error">${escapeHtml(step.result.error_message.slice(0, 500))}</div>`
        : '-'

    return `<tr>
        <td class="col-index">${index}</td>
        <td class="col-step"><span class="step-keyword">${escapeHtml(keyword)}</span>${text}</td>
        <td class="col-comment">${comment}</td>
        <td class="col-attachments">-</td>
        <td class="col-status">
            <span class="status-text status-${status}">${escapeHtml(displayStatusLabel(rawStatus))}</span>
            ${duration ? `<div class="step-duration">${duration}</div>` : ''}
        </td>
    </tr>`
}

const renderScenarioPage = (scenario: CucumberElement, projectName: string, featureName: string, runner: string): string => {
    const status = scenarioStatus(scenario)
    const visibleSteps = (scenario.steps ?? []).filter(step => !step.hidden)
    const rows = visibleSteps.map((step, i) => renderStepRow(step, i + 1)).join('\n')
    const timeSpent = formatClock(sumDurations(scenario))

    return `<section class="scenario-page">
        <div class="breadcrumb">${escapeHtml(projectName)} / ${escapeHtml(featureName)}</div>
        <h1>${escapeHtml(scenario.name)}</h1>
        <div class="meta-grid meta-grid-3">
            <div><span class="meta-label">Status</span><span class="meta-value"><span class="badge" style="background:${STATUS_COLOR[status]}">${status.toUpperCase()}</span></span></div>
            <div><span class="meta-label">Time spent</span><span class="meta-value">${timeSpent}</span></div>
            <div><span class="meta-label">Run by</span><span class="meta-value">${escapeHtml(runner)}</span></div>
        </div>
        <h2 class="section-label">Scenario</h2>
        <table class="steps-table">
            <thead><tr><th>#</th><th>Step</th><th>Comment</th><th>Attachments</th><th>Status</th></tr></thead>
            <tbody>${rows}</tbody>
        </table>
    </section>`
}

const buildDonut = (passed: number, failed: number, skipped: number): string => {
    const total = passed + failed + skipped
    if (total === 0) return `<div class="donut" style="background:#e4e7eb"></div>`

    const passedPct = (passed / total) * 100
    const failedPct = (failed / total) * 100
    const stops = [
        `${STATUS_COLOR.passed} 0% ${passedPct}%`,
        `${STATUS_COLOR.failed} ${passedPct}% ${passedPct + failedPct}%`,
        `${STATUS_COLOR.skipped} ${passedPct + failedPct}% 100%`,
    ]
    return `<div class="donut" style="background:conic-gradient(${stops.join(', ')})"></div>`
}

const buildHtml = (features: CucumberFeature[], generatedAt: Date): string => {
    const scenariosByFeature = features.map(feature => ({
        name: feature.name,
        // Cucumber's json formatter emits the Background as its own "element";
        // it isn't a scenario and has no pass/fail status worth listing.
        scenarios: (feature.elements ?? []).filter(el => el.keyword !== 'Background'),
    })).filter(f => f.scenarios.length > 0)

    const allScenarios = scenariosByFeature.flatMap(f => f.scenarios)
    const passed = allScenarios.filter(el => scenarioStatus(el) === 'passed').length
    const failed = allScenarios.filter(el => scenarioStatus(el) === 'failed').length
    const skipped = allScenarios.length - passed - failed
    const total = allScenarios.length
    const completionRate = total === 0 ? '-' : `${Math.round((passed / total) * 100)}%`

    // Derived from COMMON_CONFIG_FILE's own filename (e.g. "PizzaExpressLive"
    // from env/PizzaExpressLive.env) rather than the PROJECT env var - PROJECT
    // is only set by projects needing per-project credential overrides (see
    // loadGlobalConfig.ts), so it's blank for several projects, while every
    // run always sets COMMON_CONFIG_FILE.
    const projectName = path.basename(env('COMMON_CONFIG_FILE', 'env/common.env'), '.env')
    const reportTitle = `${projectName} test run - ${formatTimestamp(generatedAt)}`
    const host = env('UI_AUTOMATION_HOST', '')
    const runner = getRunner()
    const totalDurationNs = allScenarios.reduce((sum, el) => sum + sumDurations(el), 0)

    const featureRows = scenariosByFeature.map(({name, scenarios}) => {
        const featurePassed = scenarios.filter(el => scenarioStatus(el) === 'passed').length
        const featureFailed = scenarios.filter(el => scenarioStatus(el) === 'failed').length
        return `<tr>
            <td>${escapeHtml(name)}</td>
            <td>${featurePassed}</td>
            <td>${featureFailed}</td>
            <td>${scenarios.length}</td>
        </tr>`
    }).join('\n')

    const scenarioPages = scenariosByFeature.flatMap(({name, scenarios}) =>
        scenarios.map(scenario => renderScenarioPage(scenario, projectName, name, runner))
    ).join('\n')

    return `<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<title>${escapeHtml(reportTitle)}</title>
<style>
  * { box-sizing: border-box; }
  body { font-family: Arial, Helvetica, sans-serif; padding: 32px; color: #1f2328; font-size: 13px; }
  h1 { font-size: 22px; margin: 0 0 16px 0; }
  h2.section-label { font-size: 14px; margin: 24px 0 10px 0; }
  h3 { font-size: 14px; margin: 0 0 10px 0; }

  .meta-label { display: block; font-weight: 700; font-size: 12px; margin-bottom: 4px; }
  .meta-value { display: block; font-size: 13px; }
  .meta-grid { display: flex; gap: 32px; padding-bottom: 20px; margin-bottom: 20px; border-bottom: 1px solid #d0d7de; }
  .meta-grid > div { flex: 1; }
  .meta-grid-3 { margin-bottom: 6px; }

  .badge { display: inline-block; color: white; font-size: 11px; font-weight: bold; padding: 2px 8px; border-radius: 3px; letter-spacing: 0.03em; }

  /* --- Summary page --- */
  .summary-page { page-break-after: always; }
  .summary-columns { display: flex; gap: 48px; align-items: flex-start; margin-bottom: 24px; }
  .summary-columns > div { flex: 1; }

  .donut { width: 140px; height: 140px; border-radius: 50%; position: relative; }
  .donut::after { content: ''; position: absolute; top: 30px; left: 30px; width: 80px; height: 80px; border-radius: 50%; background: #ffffff; }

  .stat-list { list-style: none; margin: 0; padding: 0; }
  .stat-list li { display: flex; align-items: center; gap: 8px; padding: 3px 0; font-size: 13px; }
  .dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
  .stat-count { color: #57606a; }

  .completion-rate { font-size: 28px; font-weight: bold; }

  .features-table { width: 100%; border-collapse: collapse; }
  .features-table th { text-align: left; font-size: 12px; padding: 6px 8px; border-bottom: 2px solid #1f2328; }
  .features-table td { padding: 6px 8px; border-bottom: 1px solid #eaeef2; font-size: 12px; }
  .features-table td:not(:first-child), .features-table th:not(:first-child) { text-align: center; width: 80px; }

  /* --- Scenario pages --- */
  .scenario-page { page-break-before: always; }
  .breadcrumb { color: #8c959f; font-size: 11px; margin-bottom: 6px; }

  .steps-table { width: 100%; border-collapse: collapse; }
  .steps-table th { text-align: left; font-size: 12px; padding: 8px; border-bottom: 2px solid #1f2328; }
  .steps-table td { padding: 10px 8px; border-bottom: 1px solid #eaeef2; font-size: 12px; vertical-align: top; }
  .steps-table tr { page-break-inside: avoid; }
  .col-index { width: 28px; color: #57606a; }
  .col-comment { width: 220px; color: #57606a; }
  .col-attachments { width: 90px; color: #57606a; }
  .col-status { width: 100px; }
  .step-keyword { color: #0969da; font-weight: bold; margin-right: 4px; }
  .step-duration { color: #8c959f; font-size: 10px; margin-top: 2px; }
  .step-error { font-family: monospace; font-size: 10px; white-space: pre-wrap; color: ${STATUS_COLOR.failed}; }

  .status-text { font-weight: bold; }
  .status-passed { color: ${STATUS_COLOR.passed}; }
  .status-failed { color: ${STATUS_COLOR.failed}; }
  .status-skipped { color: ${STATUS_COLOR.skipped}; }
</style>
</head>
<body>

<section class="summary-page">
  <h1>${escapeHtml(reportTitle)}</h1>
  <div class="summary-columns">
    <div>
      <h3>Completion chart</h3>
      ${buildDonut(passed, failed, skipped)}
    </div>
    <div>
      <h3>Completion stats</h3>
      <ul class="stat-list">
        <li><span class="dot" style="background:${STATUS_COLOR.passed}"></span>Passed <span class="stat-count">(${passed})</span></li>
        <li><span class="dot" style="background:${STATUS_COLOR.failed}"></span>Failed <span class="stat-count">(${failed})</span></li>
        <li><span class="dot" style="background:${STATUS_COLOR.skipped}"></span>Skipped <span class="stat-count">(${skipped})</span></li>
      </ul>
    </div>
    <div>
      <h3>Completion rate</h3>
      <div class="completion-rate">${completionRate}</div>
    </div>
  </div>

  <div class="meta-grid">
    <div><span class="meta-label">Run by</span><span class="meta-value">${escapeHtml(runner)}</span></div>
    <div><span class="meta-label">Generated</span><span class="meta-value">${formatTimestamp(generatedAt)}</span></div>
    <div><span class="meta-label">Environment</span><span class="meta-value">${escapeHtml(host || '-')}</span></div>
    <div><span class="meta-label">Total step time</span><span class="meta-value">${formatClock(totalDurationNs)}</span></div>
  </div>

  <h3>Features</h3>
  <table class="features-table">
    <thead><tr><th>Feature</th><th>Passed</th><th>Failed</th><th>Total</th></tr></thead>
    <tbody>
      ${featureRows}
    </tbody>
  </table>
</section>

${scenarioPages}
</body>
</html>`
}

const run = async () => {
    const jsonReportPath = env('JSON_REPORT_FILE')
    const features: CucumberFeature[] = JSON.parse(fs.readFileSync(jsonReportPath, 'utf-8'))
    const generatedAt = new Date()
    const html = buildHtml(features, generatedAt)

    // Derived the same way as buildHtml's own reportTitle, so the PDF's
    // filename and its in-document title always agree. One project's own
    // subfolder (under the existing reports dir) keeps different projects'
    // PDFs from overwriting each other, and the date+time in the filename
    // keeps successive runs of the same project from doing the same.
    const projectName = path.basename(env('COMMON_CONFIG_FILE', 'env/common.env'), '.env')
    const defaultFilename = `${projectName}-${formatTimestampForFilename(generatedAt)}.pdf`
    const defaultPath = path.join(path.dirname(env('HTML_REPORT_FILE')), projectName, defaultFilename)
    const outputPath = env('PDF_REPORT_FILE', defaultPath)
    fs.mkdirSync(path.dirname(outputPath), {recursive: true})

    const browser = await chromium.launch()
    const page = await browser.newPage()
    await page.setContent(html, {waitUntil: 'load'})
    await page.pdf({path: outputPath, format: 'A4', margin: {top: '20px', bottom: '20px', left: '20px', right: '20px'}})
    await browser.close()

    console.log(`📄 Cucumber PDF report ${outputPath} generated successfully 👍`)
}

run().catch(error => {
    console.error('😞 Failed to generate PDF report:', error)
    process.exitCode = 1
})
