# Release process

## Automated checks

1. Run `npm ci`.
2. Run `npm run icons`.
3. Run `npm run check`.
4. Run `npm run package`.
5. Confirm the generated `.mez` contains the M source and every icon.

GitHub Actions performs these checks and publishes the unsigned `.mez` as a workflow artifact.

## Windows Power Query checks

Before a production release, use the current `Microsoft.PowerQuery.SdkTools` NuGet package on an isolated Windows release runner:

1. Exercise bounded raw, aggregated, custom-range, text, Boolean, empty-result, authentication-error, and temporary-failure cases with PQTest.
2. Run one Power BI Desktop import with Recommended connector security.
3. Run one scheduled refresh through the standard on-premises data gateway.
4. Validate Incremental Refresh with `RangeStart` and `RangeEnd`.

Do not place test credentials in the repository or command history. Use the Power Query credential store and the organization's protected runner facilities.

## PQX signing

`scripts/pack-pqx.ps1` creates an unsigned `.pqx` with Microsoft's `MakePQX`. Signing requires an organization-controlled code-signing certificate. Perform that operation through the organization's protected signing service; do not store the PFX or its password in this repository or expose the password on a shared command line.

After signing, run `scripts/verify-pqx.ps1`, record the SHA-256 digest and certificate thumbprint in the release notes, and distribute the thumbprint through managed Power BI Desktop policy. Publish both the signed `.pqx` and its checksum.

## Release blockers

- The repository owner must choose and add a software license.
- A production code-signing certificate and protected signing runner are required.
- Windows PQTest, Power BI Desktop, and gateway evidence must pass.
- Change `Beta` to `false` only after those checks pass.
