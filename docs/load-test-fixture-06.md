# Exit Codes

Every script in this repository follows the same exit-code contract.

## Contract

| Code | Meaning |
|---|---|
| 0 | success |
| 1 | usage error |
| 2 | precondition failed |
| 3 | upstream failure |

Anything above 3 is reserved for the shell itself (126, 127, 128+n).

## Preconditions

A precondition check must exit 2 rather than 1 so a caller can distinguish "you
called this wrong" from "the world is not ready yet". The retry wrapper relies
on this distinction: it retries on 2 and 3 but never on 1.

## Pitfalls

`set -e` aborts on the first failing command, so a precondition check placed
after a pipeline inherits the pipeline's status. Several scripts check the
precondition after the fetch, which means a network failure is reported as a
precondition failure.

## Logging

All output goes to stderr so stdout stays parseable. Scripts that print to
stdout break callers that capture the result.
