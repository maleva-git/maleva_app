# Design

## Context

`features/mail_monitor/report`; backend contract in its change of the same name.

## Goals / Non-Goals

**Goals:** same numbers as the web. **Non-Goals:** computing bookings on the device.

## Decisions

- Models read the Java fields as sent; reading reasons join `reasonTexts`; booking page is a pushed page with its own
  small cubit.

## Risks / Trade-offs

- [Backend not deployed] -> booking page shows the server's message; the tab works as before.
