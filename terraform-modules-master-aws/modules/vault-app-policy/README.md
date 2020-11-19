# Vault App Policy

This module serves as an addon to add application service policies to access
key / value secrets stored in your already set-up Vault.

## Description

Generate two policies that affect the KV path at `"${var.kv_path}/app/${var.app}"`.

The `app` policy will restrict to only readonly access
The `dev` policy will allow read/write access.

The policies will have the following naming convention if `${var.prefix}` is set as a non-empty
string:

- Read-only  (app): `"${var.prefix}_${var.app}_app"`
- Read-Write (dev): `"${var.prefix}_${var.app}_dev"`

Otherwise, without prefix:

- Read-only  (app): `"${var.app}_app"`
- Read-Write (dev): `"${var.app}_dev"`

__Be sure not to use same app name across all your application services!__

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
