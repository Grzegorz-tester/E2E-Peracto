// Marks Qase test cases as "automated" (API value 2), taking the case IDs from
// a Qase JSON export (e.g. the WAT project's "Watco VAT functionality" suite).
// Each case's live title is checked against the export before it is touched,
// so a stale export can't flip the wrong case.
//
// Dry run by default; pass --apply to write. Needs QASE_API_TOKEN in .env.
//   npx ts-node scripts/qase-mark-automated.ts <export.json> [--project WAT] [--apply]

import fs from 'fs'
import dotenv from 'dotenv'

dotenv.config()

const AUTOMATED = 2

const args = process.argv.slice(2)
const exportPath = args.find(a => !a.startsWith('--'))
const apply = args.includes('--apply')
const projectIdx = args.indexOf('--project')
const project = projectIdx >= 0 ? args[projectIdx + 1] : 'WAT'
const token = process.env.QASE_API_TOKEN

if (!exportPath) throw new Error('Usage: qase-mark-automated.ts <export.json> [--project WAT] [--apply]')
if (!token) throw new Error('QASE_API_TOKEN is not set (add it to .env)')

type ExportSuite = { suites: ExportSuite[]; cases: { id: number; title: string }[] }

const collectCases = (suites: ExportSuite[]): { id: number; title: string }[] =>
    suites.flatMap(s => [...s.cases, ...collectCases(s.suites)])

const qase = async (method: string, url: string, body?: object) => {
    const res = await fetch(`https://api.qase.io/v1${url}`, {
        method,
        headers: { Token: token, 'Content-Type': 'application/json', accept: 'application/json' },
        body: body ? JSON.stringify(body) : undefined,
    })
    const json: any = await res.json().catch(() => ({}))
    if (!res.ok || json.status === false) throw new Error(`${method} ${url} -> ${res.status} ${JSON.stringify(json)}`)
    return json.result
}

const run = async () => {
    const cases = collectCases(JSON.parse(fs.readFileSync(exportPath, 'utf-8')).suites)
    let changed = 0, already = 0
    const problems: string[] = []

    for (const c of cases) {
        const live = await qase('GET', `/case/${project}/${c.id}`)
        if (live.title.trim() !== c.title.trim()) {
            problems.push(`${project}-${c.id}: live title "${live.title}" != export "${c.title}"`)
            continue
        }
        if (live.automation === AUTOMATED) { already++; continue }
        if (apply) await qase('PATCH', `/case/${project}/${c.id}`, { automation: AUTOMATED })
        changed++
    }

    console.log(`${cases.length} cases: ${changed} ${apply ? 'marked automated' : 'would be marked automated'}, ${already} already automated, ${problems.length} skipped`)
    problems.forEach(p => console.log('  SKIPPED ' + p))
    if (!apply && changed) console.log('Dry run only - re-run with --apply to write.')
}

run().catch(e => { console.error(e.message); process.exit(1) })
