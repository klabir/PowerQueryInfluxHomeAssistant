# Security policy

## Supported versions

Security fixes are applied to the latest released version.

## Reporting a vulnerability

Use the repository's private GitHub security-advisory form. Do not open a public issue for credentials, authentication bypasses, or sensitive diagnostic output.

## Credential handling

- Credentials are read from the Power Query credential store with `Extension.CurrentCredential()`.
- Credentials must never be placed in M queries, repository files, issue reports, screenshots, or logs.
- Use a dedicated read-only InfluxDB account limited to the required database.
- Prefer HTTPS. HTTP Basic authentication is only Base64 encoding and does not protect credentials or data in transit.

## Deployment

Production deployments should use a signed `.pqx` whose certificate thumbprint is distributed by the organization's device-management policy. Verify the signature before deployment.
