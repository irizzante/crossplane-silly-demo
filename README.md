# Reproduce the problem

1. Run ./setup.sh
1. Run `kubectl describe composite`
1. Observe the error message:
```
Status:
  Conditions:
    Last Transition Time:  2024-11-26T20:39:42Z
    Message:               cannot compose resources: cannot run Composition pipeline step "aws": cannot get gRPC client connection for Function "irizzant-silly-demoaws": cannot find an active FunctionRevision (a FunctionRevision with spec.desiredState: Active)
    Reason:                ReconcileError
    Status:                False
    Type:                  Synced
```