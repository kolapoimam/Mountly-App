# Contributing to Mountly

Thanks for helping make Mountly better. This guide explains how to set up the project and what makes a pull request easy to review.

## Ways to help

You don't need to write Swift to contribute.

- **Test with real drives.** Tell us which drives and filesystems work, and which don't.
- **Report bugs.** Clear steps to reproduce are the most useful thing you can send.
- **Improve wording.** Error messages, help text and docs should be easy for anyone to follow.
- **Write code.** Fix bugs, add tests or build features from the issue list.
- **Improve the website.** The landing page lives in `src/` and `public/` at the root of the repo.

## Set up the app

You need an Apple Silicon Mac with macOS 14 or later and Xcode 16 or later.

```bash
git clone https://github.com/<your-username>/Mountly-App.git
cd Mountly-App/app
swift build
swift test --filter MountlyCoreTests
```

To work on NTFS mounting or run the integration tests, install the dev tools:

```bash
brew install --cask macfuse
brew tap gromgit/fuse
brew install gromgit/fuse/ntfs-3g-mac
```

The integration tests build a throwaway NTFS image in a temp folder. They never touch a real disk, and they skip themselves if the tools above aren't installed.

Run these from the `app` folder. More detail is in [app/docs/DEVELOPMENT.md](app/docs/DEVELOPMENT.md).

## Set up the website

From the root of the repo:

```bash
npm install
npm run dev
```

## Before you start

- For anything bigger than a small fix, open an issue first so we can agree on the approach.
- If you want to take an existing issue, leave a comment so nobody else picks it up at the same time.

## Ground rules for code

Mountly handles people's files, so a few rules are firm.

- Never add code that formats, erases, partitions or repairs a drive.
- Never claim a drive is writable without a real write test.
- Never add a new method to the privileged helper without discussing it in an issue first.
- Never build shell command strings. Use `ProcessRunner` with an argument array.
- Keep `MountlyCore` free of SwiftUI and AppKit so it stays easy to test.

Read [app/docs/SECURITY.md](app/docs/SECURITY.md) before you change anything in `app/Sources/MountlyCore/Filesystem` or `app/Sources/MountlyHelperTool`.

## Pull requests

- Keep each pull request focused on one change.
- Add or update tests for any change in behaviour.
- Make sure `swift build` and `swift test --filter MountlyCoreTests` pass.
- Add screenshots for any UI change.
- Update the docs if you change how something works.
- Write commit messages in the present tense, for example `Add exFAT label to drive list` or `Fix eject when a transfer is cancelled`.

## Reporting bugs

Use the bug report form. Include your macOS version, your Mac model, the drive's filesystem and what you saw. The **Diagnostics** screen in Mountly has a copy button that collects most of this for you.

## Security problems

Please don't report security problems in public issues. See [SECURITY.md](SECURITY.md).

## Code of conduct

By taking part you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
