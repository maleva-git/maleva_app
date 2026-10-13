# Design

## Context

`features/mail_monitor/report` (change `mail-response-report-tab`); backend contract in the backend change of the
same name.

## Goals / Non-Goals

**Goals:** same judgement as the web. **Non-Goals:** computing categories on the device.

## Decisions

- New fields read in `ResponseRow` / `ResponseReport`; categories and reasons from the API; reason sentences in
  one map with tests; read aloud speaks the structured points' text.

## Risks / Trade-offs

- [Backend not deployed] -> fields missing: the tab keeps today's view.
