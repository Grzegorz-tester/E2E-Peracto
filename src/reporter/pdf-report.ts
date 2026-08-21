import dotenv from 'dotenv'
import fs from 'fs'
import path from 'path'
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

const escapeHtml = (value: string) =>
    value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

const STATUS_LABEL: Record<Status, string> = {
    passed: 'PASS',
    failed: 'FAIL',
    skipped: 'SKIPPED',
}

const STATUS_COLOR: Record<Status, string> = {
    passed: '#1a7f37',
    failed: '#cf222e',
    skipped: '#9a6700',
}

const STEP_STATUS_SYMBOL: Record<string, string> = {
    passed: '✓',
    failed: '✗',
    skipped: '○',
    pending: '○',
    undefined: '○',
    ambiguous: '○',
}

const formatDuration = (nanoseconds?: number): string => {
    if (!nanoseconds) return ''
    const ms = nanoseconds / 1_000_000
    if (ms < 1000) return `${Math.round(ms)}ms`
    return `${(ms / 1000).toFixed(1)}s`
}

const renderStep = (step: CucumberStep): string => {
    const status = (step.result?.status ?? 'skipped') as Status
    const symbol = STEP_STATUS_SYMBOL[status] ?? '○'
    const text = `${step.keyword ?? ''}${step.name ?? ''}`.trim()
    const duration = formatDuration(step.result?.duration)
    const errorBlock = step.result?.error_message
        ? `<div class="step-error">${escapeHtml(step.result.error_message)}</div>`
        : ''
    return `<li class="step step-${status}">
        <span class="step-symbol" style="color:${STATUS_COLOR[status] ?? '#57606a'}">${symbol}</span>
        <span class="step-text">${escapeHtml(text)}</span>
        <span class="step-duration">${duration}</span>
        ${errorBlock}
    </li>`
}

const renderScenario = (scenario: CucumberElement): string => {
    const status = scenarioStatus(scenario)
    const tags = (scenario.tags ?? []).map(tag => `<span class="tag">${escapeHtml(tag.name)}</span>`).join('')
    const visibleSteps = (scenario.steps ?? []).filter(step => !step.hidden)
    const steps = visibleSteps.map(renderStep).join('\n')

    return `<div class="scenario scenario-${status}">
        <div class="scenario-header">
            <span class="scenario-status" style="background:${STATUS_COLOR[status]}">${STATUS_LABEL[status]}</span>
            <span class="scenario-name">${escapeHtml(scenario.name)}</span>
            ${tags}
        </div>
        <ul class="steps">
            ${steps}
        </ul>
    </div>`
}

const buildHtml = (features: CucumberFeature[]): string => {
    const scenariosByFeature = features.map(feature => ({
        name: feature.name,
        uri: feature.uri ?? '',
        // Cucumber's json formatter emits the Background as its own "element";
        // it isn't a scenario and has no pass/fail status worth listing.
        scenarios: (feature.elements ?? []).filter(el => el.keyword !== 'Background'),
    })).filter(f => f.scenarios.length > 0)

    const allScenarios = scenariosByFeature.flatMap(f => f.scenarios)
    const passed = allScenarios.filter(el => scenarioStatus(el) === 'passed').length
    const failed = allScenarios.filter(el => scenarioStatus(el) === 'failed').length
    const skipped = allScenarios.length - passed - failed

    const tocItems = scenariosByFeature.map(({name, scenarios}) => {
        const featurePassed = scenarios.filter(el => scenarioStatus(el) === 'passed').length
        const featureFailed = scenarios.filter(el => scenarioStatus(el) === 'failed').length
        return `<li><span>${escapeHtml(name)}</span><span class="toc-count">${featurePassed}/${scenarios.length} passed${featureFailed ? `, ${featureFailed} failed` : ''}</span></li>`
    }).join('\n')

    const featureSections = scenariosByFeature.map(({name, uri, scenarios}) => {
        const scenarioHtml = scenarios.map(renderScenario).join('\n')
        return `<div class="feature">
            <h2>${escapeHtml(name)}</h2>
            <div class="feature-uri">${escapeHtml(uri)}</div>
            ${scenarioHtml}
        </div>`
    }).join('\n')

    // Derived from COMMON_CONFIG_FILE's own filename (e.g. "PizzaExpressLive"
    // from env/PizzaExpressLive.env) rather than the PROJECT env var - PROJECT
    // is only set by projects needing per-project credential overrides (see
    // loadGlobalConfig.ts), so it's blank for several projects, while every
    // run always sets COMMON_CONFIG_FILE.
    const projectName = path.basename(env('COMMON_CONFIG_FILE', 'env/common.env'), '.env')
    const today = new Date().toISOString().slice(0, 10)
    const reportTitle = `${projectName} - ${today}`
    const host = env('UI_AUTOMATION_HOST', '')

    return `<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<title>${escapeHtml(reportTitle)}</title>
<style>
  * { box-sizing: border-box; }
  body { font-family: Arial, Helvetica, sans-serif; padding: 32px; color: #1f2328; font-size: 13px; }
  h1 { font-size: 20px; margin-bottom: 2px; }
  .subtitle { color: #57606a; font-size: 13px; margin-bottom: 4px; }
  .summary { color: #57606a; margin-bottom: 20px; font-size: 12px; }
  .summary strong.passed { color: ${STATUS_COLOR.passed}; }
  .summary strong.failed { color: ${STATUS_COLOR.failed}; }
  .summary strong.skipped { color: ${STATUS_COLOR.skipped}; }

  .toc { margin-bottom: 28px; border: 1px solid #d0d7de; border-radius: 6px; padding: 12px 16px; }
  .toc h3 { margin: 0 0 8px 0; font-size: 13px; }
  .toc ul { list-style: none; margin: 0; padding: 0; }
  .toc li { display: flex; justify-content: space-between; padding: 3px 0; border-bottom: 1px solid #f0f2f4; }
  .toc li:last-child { border-bottom: none; }
  .toc-count { color: #57606a; }

  .feature { margin-bottom: 24px; page-break-inside: avoid; }
  h2 { font-size: 15px; margin: 0 0 2px 0; padding-bottom: 4px; border-bottom: 1px solid #d0d7de; }
  .feature-uri { color: #8c959f; font-size: 10px; margin-bottom: 10px; font-family: monospace; }

  .scenario { margin: 0 0 12px 0; padding: 8px 12px; border: 1px solid #d0d7de; border-radius: 6px; page-break-inside: avoid; }
  .scenario-failed { border-color: ${STATUS_COLOR.failed}; background: #fff8f8; }
  .scenario-header { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; flex-wrap: wrap; }
  .scenario-status { color: white; font-size: 10px; font-weight: bold; padding: 1px 6px; border-radius: 3px; letter-spacing: 0.03em; }
  .scenario-name { font-weight: bold; }
  .tag { color: #57606a; font-size: 10px; background: #f0f2f4; border-radius: 3px; padding: 1px 5px; }

  .steps { list-style: none; margin: 0; padding: 0; }
  .step { display: flex; align-items: baseline; gap: 6px; padding: 1px 0; font-size: 12px; }
  .step-symbol { width: 12px; flex-shrink: 0; font-weight: bold; }
  .step-text { flex: 1; }
  .step-duration { color: #8c959f; font-size: 10px; flex-shrink: 0; }
  .step-failed .step-text { color: ${STATUS_COLOR.failed}; }
  .step-skipped .step-text, .step-pending .step-text { color: #8c959f; }
  .step-error { margin: 3px 0 6px 18px; padding: 6px 8px; background: #fff1f0; border-left: 3px solid ${STATUS_COLOR.failed}; font-family: monospace; font-size: 10px; white-space: pre-wrap; color: #82071e; max-height: 120px; overflow: hidden; }
</style>
</head>
<body>
<h1>${escapeHtml(reportTitle)}</h1>
${host ? `<div class="subtitle">${escapeHtml(host)}</div>` : ''}
<div class="summary">
  <strong class="passed">${passed} passed</strong>,
  <strong class="failed">${failed} failed</strong>,
  <strong class="skipped">${skipped} skipped</strong>
  &mdash; ${allScenarios.length} scenarios total &mdash; generated ${new Date().toISOString()}
</div>
<div class="toc">
  <h3>Features tested</h3>
  <ul>
    ${tocItems}
  </ul>
</div>
${featureSections}
</body>
</html>`
}

const run = async () => {
    const jsonReportPath = env('JSON_REPORT_FILE')
    const features: CucumberFeature[] = JSON.parse(fs.readFileSync(jsonReportPath, 'utf-8'))
    const html = buildHtml(features)

    const outputPath = env('PDF_REPORT_FILE', path.join(path.dirname(env('HTML_REPORT_FILE')), 'cucumber-pdf-report.pdf'))

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
