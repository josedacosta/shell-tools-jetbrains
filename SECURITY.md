# Security Policy

## Scope

These scripts run locally on your macOS system and:
- Do not collect or transmit any data
- Do not connect to the internet
- Only access JetBrains-related files in standard macOS locations

## Reporting a Vulnerability

If you discover a security issue, please:

1. **Do not** open a public issue
2. Email the maintainer directly with:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact

## Best Practices

When using these scripts:

1. **Always use `--dry-run` first** to preview what will be deleted
2. **Back up important data** before running `deep_uninstall.sh`
3. **Review the script source** before execution if concerned
4. **Download only from the official repository**

## Script Permissions

These scripts require:
- Read access to `~/Library/` directories
- Write/delete access for uninstallation
- No sudo/root access required
