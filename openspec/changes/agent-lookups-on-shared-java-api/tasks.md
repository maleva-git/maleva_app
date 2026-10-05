## 1. Client

- [x] 1.1 `AgentApi`, 204 as none in `MasterResponse`, the models' `fromJava`; every agent / agent company caller moved; adapter entries, mappers and constants removed. Verify: `test/core/lookups/agent_api_test.dart`, lookup and adapter tests; analyzer 0 errors, warnings equal to the baseline.
- [x] 1.2 Full suite. Verify: 323 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: agent company and agent pickers on Sales Order (loading and off-loading agents), and the agent names on Sale Order details.
- [ ] 2.2 Next lookup groups: products, addresses, trucks, drivers.
