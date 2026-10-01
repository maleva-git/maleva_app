# Bluetooth device selection and printing

## Purpose

Describe discovery and persistence of a Bluetooth printer connection and the separate barcode printing helper.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/core/bluetooth/view/Bluetooth_tab.dart](../../../lib/core/bluetooth/view/Bluetooth_tab.dart)
- [lib/core/bluetooth/bloc/bluetooth_bloc.dart](../../../lib/core/bluetooth/bloc/bluetooth_bloc.dart)
- [lib/core/utils/printer_helper.dart](../../../lib/core/utils/printer_helper.dart)
- [android/app/src/main/AndroidManifest.xml](../../../android/app/src/main/AndroidManifest.xml)

## Requirements

### Requirement: Scan and label nearby devices

The Bluetooth page SHALL offer a scan with a ten-second timeout and display Unknown Device for an empty device name.

#### Scenario: Unnamed device
- **WHEN** a scan result has an empty name
- **THEN** the result displays Unknown Device and the available device address.

#### Scenario: Bluetooth off
- **WHEN** the page observes Bluetooth disabled
- **THEN** it displays instructions to turn on Bluetooth to scan.

### Requirement: Persist connected device

After a selected device connects, the Bluetooth flow SHALL store its name, address, and type under BlueTooth and return to its caller after displaying success.

#### Scenario: Connection established
- **WHEN** the connected event arrives for a selected device
- **THEN** the saved device record is updated and the page closes with Connected Successfully.

### Requirement: Handle automatic connection failure

Opening Bluetooth with print data SHALL attempt to connect to the first remembered device, and report failure if no saved device exists or connection throws.

#### Scenario: No saved printer
- **WHEN** automatic connection is requested without a saved device
- **THEN** the flow reports that no saved Bluetooth device was found and the print-mode page closes.

### Requirement: Send prepared printer commands

The separate printing helper SHALL prepare printer command bytes from barcode records and write those bytes through the Bluetooth plugin when its print routine runs.

#### Scenario: Print helper execution
- **WHEN** printdata is called with barcode records
- **THEN** the helper builds command data and writes the resulting byte sequences.

## Clarifications

Q09 covers printer models, runtime permissions, duplicate global printer state, and caller responsibility for printing after connection. Passing printData to BluetoothPage alone does not prove a print job is sent. See [the clarification register](../../baseline/clarifications.md).
