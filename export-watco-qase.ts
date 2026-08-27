// Exports every Watco market's Cucumber feature files as a Qase-importable
// JSON doc (watco-qase-export.json), matching the exact `suites`/`cases`
// nested schema confirmed to import successfully into Qase (verified
// against a real working export, 2026-08-26 - the previous version of this
// script used Qase's *API* bulk-case schema instead, which the "Import
// Data" UI feature rejected outright with "Data is invalid").
//
// Re-run after adding/editing Watco feature files:
//   npx ts-node export-watco-qase.ts

import fs from 'fs'
import path from 'path'
import { Parser, AstBuilder, GherkinClassicTokenMatcher } from '@cucumber/gherkin'
import { IdGenerator } from '@cucumber/messages'

type QaseCase = {
    title: string
    description: string
}
type QaseSuite = {
    title: string
    suites?: QaseSuite[]
    cases?: QaseCase[]
}

const MARKETS: { dir: string; label: string }[] = [
    { dir: 'Watco_features', label: 'Watco UK' },
    { dir: 'Watco_BEFR_features', label: 'Watco BE (FR)' },
    { dir: 'Watco_BENL_features', label: 'Watco BE (NL)' },
    { dir: 'Watco_DE_features', label: 'Watco DE' },
    { dir: 'Watco_FR_features', label: 'Watco FR' },
    { dir: 'Watco_IE_features', label: 'Watco IE' },
    { dir: 'Watco_NL_features', label: 'Watco NL' },
    { dir: 'Watco_PL_features', label: 'Watco PL' },
]

const FEATURES_ROOT = path.join(process.cwd(), 'src', 'features')

const renderStep = (step: any): string => {
    const keyword = (step.keyword ?? '').trim()
    const text = step.text ?? ''
    let line = `${keyword} ${text}`.trim()
    if (step.dataTable) {
        const rows = step.dataTable.rows.map((row: any) =>
            '  | ' + row.cells.map((c: any) => c.value).join(' | ') + ' |'
        )
        line += '\n' + rows.join('\n')
    }
    if (step.docString) {
        line += `\n  """\n${step.docString.content}\n  """`
    }
    return line
}

const renderExamples = (examplesList: any[]): string => {
    if (!examplesList || examplesList.length === 0) return ''
    return examplesList.map(ex => {
        const header = '  | ' + ex.tableHeader.cells.map((c: any) => c.value).join(' | ') + ' |'
        const rows = ex.tableBody.map((row: any) =>
            '  | ' + row.cells.map((c: any) => c.value).join(' | ') + ' |'
        )
        return `\n  Examples:\n${header}\n${rows.join('\n')}`
    }).join('\n')
}

const parseFeatureFile = (filePath: string): any => {
    const source = fs.readFileSync(filePath, 'utf-8')
    const uuidFn = IdGenerator.uuid()
    const builder = new AstBuilder(uuidFn)
    const matcher = new GherkinClassicTokenMatcher()
    const parser = new Parser(builder, matcher)
    return parser.parse(source)
}

const run = () => {
    let totalFeatureFiles = 0
    let totalScenarios = 0
    const skipped: string[] = []
    const marketSuites: QaseSuite[] = []

    for (const market of MARKETS) {
        const dirPath = path.join(FEATURES_ROOT, market.dir)
        if (!fs.existsSync(dirPath)) continue

        const featureFiles = fs.readdirSync(dirPath).filter(f => f.endsWith('.feature')).sort()
        const featureSuites: QaseSuite[] = []

        for (const fileName of featureFiles) {
            const filePath = path.join(dirPath, fileName)
            if (fs.statSync(filePath).size === 0) {
                skipped.push(`${market.dir}/${fileName} (empty file)`)
                continue
            }
            totalFeatureFiles++

            let doc: any
            try {
                doc = parseFeatureFile(filePath)
            } catch (e) {
                skipped.push(`${market.dir}/${fileName} (parse error: ${e instanceof Error ? e.message : e})`)
                continue
            }

            const feature = doc.feature
            if (!feature) {
                skipped.push(`${market.dir}/${fileName} (no Feature: block)`)
                continue
            }

            const background = feature.children.find((c: any) => c.background)?.background
            const backgroundText = background
                ? (background.steps ?? []).map(renderStep).join('\n')
                : ''

            const scenarioChildren = feature.children.filter((c: any) => c.scenario)
            const cases: QaseCase[] = []

            for (const child of scenarioChildren) {
                const scenario = child.scenario
                totalScenarios++

                const stepsText = (scenario.steps ?? []).map(renderStep).join('\n')
                const examplesText = renderExamples(scenario.examples)
                const description = [backgroundText, stepsText, examplesText]
                    .filter(Boolean)
                    .join('\n')

                cases.push({
                    title: scenario.name || '(untitled scenario)',
                    description,
                })
            }

            if (cases.length > 0) {
                featureSuites.push({ title: feature.name, cases })
            }
        }

        if (featureSuites.length > 0) {
            marketSuites.push({ title: market.label, suites: featureSuites })
        }
    }

    const output: { suites: QaseSuite[] } = {
        suites: [
            {
                title: 'Watco Regression',
                suites: marketSuites,
            },
        ],
    }

    const outPath = path.join(process.cwd(), 'watco-qase-export.json')
    fs.writeFileSync(outPath, JSON.stringify(output, null, 2))
    console.log(`Wrote ${totalScenarios} cases from ${totalFeatureFiles} feature files across ${MARKETS.length} markets to ${outPath}`)
    if (skipped.length > 0) {
        console.log('Skipped:')
        skipped.forEach(s => console.log(' -', s))
    }
}

run()
