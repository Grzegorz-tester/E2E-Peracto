// Text attached to a scenario's passing attempt by hooks.ts when an earlier
// attempt of the same scenario failed and was retried. Shared with the
// reporters, which read it back out of report.json's embeddings.
export const RETRY_PASS_MARKER = 'PASSED ON RETRY';
