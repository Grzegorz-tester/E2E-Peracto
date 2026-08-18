import dotenv from 'dotenv'
import fs from 'fs'
import path from 'path'
import { chromium } from 'playwright'
import { env } from '../env/parseEnv'

dotenv.config({path: env('COMMON_CONFIG_FILE', 'env/common.env')})

type CucumberStepResult = { status?: string }
type CucumberStep = { result?: CucumberStepResult }
type CucumberElement = { name: string; keyword: string; steps?: CucumberStep[] }
type CucumberFeature = { name: string; elements?: CucumberElement[] }

const scenarioStatus = (element: CucumberElement): 'passed' | 'failed' | 'skipped' => {
    const statuses = (element.steps ?? []).map(step => step.result?.status)
    if (statuses.includes('failed')) return 'failed'
    if (statuses.length > 0 && statuses.every(status => status === 'passed')) return 'passed'
    return 'skipped'
}

const escapeHtml = (value: string) =>
    value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

const STATUS_LABEL: Record<ReturnType<typeof scenarioStatus>, string> = {
    passed: 'PASS',
    failed: 'FAIL',
    skipped: 'SKIPPED',
}

const STATUS_COLOR: Record<ReturnType<typeof scenarioStatus>, string> = {
    passed: '#1a7f37',
    failed: '#cf222e',
    skipped: '#9a6700',
}

const buildHtml = (features: CucumberFeature[]): string => {
    const scenariosByFeature = features.map(feature => ({
        name: feature.name,
        // Cucumber's json formatter emits the Background as its own "element";
        // it isn't a scenario and has no pass/fail status worth listing.
        scenarios: (feature.elements ?? []).filter(el => el.keyword !== 'Background'),
    }))

    const allScenarios = scenariosByFeature.flatMap(f => f.scenarios)
    const passed = allScenarios.filter(el => scenarioStatus(el) === 'passed').length
    const failed = allScenarios.filter(el => scenarioStatus(el) === 'failed').length
    const skipped = allScenarios.length - passed - failed

    const featureSections = scenariosByFeature.map(({name, scenarios}) => {
        const items = scenarios.map(scenario => {
            const status = scenarioStatus(scenario)
            return `<li>${escapeHtml(scenario.name)} &mdash; <strong style="color:${STATUS_COLOR[status]}">${STATUS_LABEL[status]}</strong></li>`
        }).join('\n')
        return `<h2>${escapeHtml(name)}</h2>\n<ul>\n${items}\n</ul>`
    }).join('\n')

    return `<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<style>
  body { font-family: Arial, Helvetica, sans-serif; padding: 32px; color: #1f2328; }
  h1 { font-size: 20px; margin-bottom: 4px; }
  .summary { color: #57606a; margin-bottom: 24px; font-size: 13px; }
  h2 { font-size: 15px; margin-top: 20px; margin-bottom: 6px; border-bottom: 1px solid #d0d7de; padding-bottom: 4px; }
  ul { margin: 0 0 12px 0; padding-left: 20px; }
  li { margin-bottom: 4px; font-size: 13px; }
</style>
</head>
<body>
<h1>Cucumber Test Report</h1>
<div class="summary">${passed} passed, ${failed} failed, ${skipped} skipped, ${allScenarios.length} total &mdash; generated ${new Date().toISOString()}</div>
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
