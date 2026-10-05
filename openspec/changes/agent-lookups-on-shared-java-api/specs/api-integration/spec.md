## ADDED Requirements

### Requirement: Agent pickers on the shared API

The agent and agent company pickers SHALL read `/api/agents/select-all` and
`/api/agent-companies/company/{companyId}` directly and their Java fields, without the .NET-shaped
adapter.

#### Scenario: Agents of an agent company
- **WHEN** agent company 2 is picked on a sales order
- **THEN** the app lists `/api/agents/select-all?jobId=2` and shows each agent's name

#### Scenario: No agent companies
- **WHEN** the agent company list answers 204
- **THEN** the picker is empty, not an error
