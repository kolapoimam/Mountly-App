# Security Policy

Mountly works with people's drives and runs a small privileged helper, so security reports matter a lot.

## Reporting a problem

Please don't open a public issue. Email **kolapoimam1@gmail.com** with:

- what you found and where in the code
- steps to reproduce it
- what an attacker could do with it

You'll get a reply within a few days. Once a fix is ready, you'll be credited in the release notes unless you'd rather not be.

## Supported versions

Only the latest release gets security fixes.

## How Mountly is designed to stay safe

The full model is in [app/docs/SECURITY.md](app/docs/SECURITY.md). It covers the four helper methods, how requests are checked, and why the app is not sandboxed.
