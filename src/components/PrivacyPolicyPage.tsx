import { HardDrive, ArrowLeft, Shield, Lock, EyeOff, ServerOff, ExternalLink } from 'lucide-react';

interface PrivacyPolicyPageProps {
  onBackToHome: () => void;
}

export function PrivacyPolicyPage({ onBackToHome }: PrivacyPolicyPageProps) {
  const downloadUrl = 'https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing';

  return (
    <div className="min-h-screen bg-stone-950 text-stone-100 flex flex-col justify-between">
      {/* Top Bar / Header */}
      <header className="border-b border-stone-800/80 bg-stone-950/80 backdrop-blur-md sticky top-0 z-40">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <button
            type="button"
            onClick={onBackToHome}
            className="flex items-center gap-2 text-stone-300 hover:text-white transition-colors group"
          >
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-stone-900 border border-stone-800 text-blue-400 group-hover:border-stone-700">
              <HardDrive className="h-3.5 w-3.5" aria-hidden="true" />
            </div>
            <span className="font-bold text-white tracking-tight text-sm">
              Mountly
            </span>
          </button>

          <div className="flex items-center gap-3">
            <a
              href={downloadUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs font-semibold px-3.5 py-1.5 rounded-full bg-blue-600 hover:bg-blue-500 text-white transition-all shadow-sm"
            >
              Download
            </a>
            <button
              type="button"
              onClick={onBackToHome}
              className="inline-flex items-center gap-1.5 text-xs text-stone-400 hover:text-white px-3 py-1.5 rounded-full border border-stone-800 hover:bg-stone-900 transition-colors"
            >
              <ArrowLeft className="h-3.5 w-3.5" />
              <span>Back to Home</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Privacy Policy Content */}
      <main className="flex-1 py-12 sm:py-16">
        <article className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8 space-y-10">
          {/* Header */}
          <div className="space-y-3 pb-8 border-b border-stone-800/80">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-medium bg-stone-900 border border-stone-800 text-blue-400">
              <Shield className="h-3.5 w-3.5" />
              <span>Privacy & Transparency</span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight text-white">
              Privacy Policy
            </h1>
            <p className="text-sm text-stone-400">
              Last updated: September 2026 · Mountly for macOS
            </p>
          </div>

          {/* Quick Summary Card */}
          <div className="rounded-2xl border border-stone-800 bg-stone-900/40 p-5 sm:p-6 space-y-3">
            <h2 className="text-base font-bold text-white flex items-center gap-2">
              <Lock className="h-4 w-4 text-blue-400" />
              <span>The Short Version</span>
            </h2>
            <p className="text-sm text-stone-300 leading-relaxed">
              Mountly is an independent macOS disk utility designed with complete privacy in mind. We do not collect, store, transmit, or monetize any of your data. Mountly runs entirely on your local machine and never communicates with any external servers.
            </p>
          </div>

          {/* Detailed Sections */}
          <div className="space-y-8 text-sm text-stone-300 leading-relaxed">
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <ServerOff className="h-4 w-4 text-emerald-400" />
                <span>1. Zero Telemetry & Analytics</span>
              </h2>
              <p>
                Mountly contains no third-party tracking scripts, software development kits (SDKs), advertising libraries, or telemetry modules.
              </p>
              <ul className="list-disc list-inside space-y-1.5 text-stone-400 pl-2">
                <li>No session logs or usage counts</li>
                <li>No device identifiers or hardware telemetry</li>
                <li>No analytics or marketing tracking cookies</li>
                <li>No automated remote crash reporting</li>
              </ul>
            </section>

            <section className="space-y-3">
              <h2 className="text-lg font-bold text-white flex items-center gap-2">
                <EyeOff className="h-4 w-4 text-emerald-400" />
                <span>2. Local macOS Operations Only</span>
              </h2>
              <p>
                All disk discovery, partition queries, and volume mounting actions are executed locally through native macOS system frameworks (such as DiskArbitration and Apple File System interfaces). Mountly operates 100% offline and makes zero background network connections.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-lg font-bold text-white">
                3. Your Drives and File Contents
              </h2>
              <p>
                Mountly never indexes, parses, caches, or inspects the contents of files stored on your external drives. When a volume is mounted with read/write access, all file interactions (copying, moving, opening, editing) occur directly between your chosen macOS applications (such as Finder) and the drive itself.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-lg font-bold text-white">
                4. System Permissions
              </h2>
              <p>
                To attach and mount non-native filesystems (like NTFS) with full read and write capabilities, macOS may prompt you for system authorization (such as disk helper privileges). These privileges are strictly utilized to execute system mount and unmount commands and are never used to access personal user directories.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-lg font-bold text-white">
                5. Website & Downloads
              </h2>
              <p>
                This website is a static informational landing page. We do not use cookies or trackers. Downloads are provided directly via verified links without intermediary data collection.
              </p>
            </section>

            <section className="space-y-3">
              <h2 className="text-lg font-bold text-white">
                6. Contact & Open Source Inquiries
              </h2>
              <p>
                If you have questions about Mountly’s privacy principles or wish to audit the code, you can inspect the project or reach out directly:
              </p>
              <div className="pt-2 flex flex-wrap gap-4">
                <a
                  href="https://github.com/kolapoimam/mountly"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-xs text-blue-400 hover:text-blue-300 font-medium"
                >
                  <span>Mountly GitHub Repository</span>
                  <ExternalLink className="h-3 w-3" />
                </a>
                <a
                  href="https://kolapo.ng"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-xs text-blue-400 hover:text-blue-300 font-medium"
                >
                  <span>Kolapo Imam Website</span>
                  <ExternalLink className="h-3 w-3" />
                </a>
              </div>
            </section>
          </div>

          {/* Bottom Back Button */}
          <div className="pt-8 border-t border-stone-800/80 flex flex-col sm:flex-row items-center justify-between gap-4">
            <button
              type="button"
              onClick={onBackToHome}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full border border-stone-700 bg-stone-900 hover:bg-stone-800 text-stone-200 text-xs font-medium transition-colors"
            >
              <ArrowLeft className="h-3.5 w-3.5" />
              <span>Back to Mountly</span>
            </button>

            <a
              href={downloadUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold shadow-sm transition-all"
            >
              <span>Download Mountly</span>
            </a>
          </div>
        </article>
      </main>

      {/* Connected Footer without divider */}
      <footer className="border-t border-stone-800/80 bg-stone-950 text-stone-400 py-10">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-stone-500">
            <span>
              Built by{' '}
              <a
                href="https://kolapo.ng"
                target="_blank"
                rel="noopener noreferrer"
                className="font-medium text-stone-300 hover:text-white underline underline-offset-4 decoration-stone-700 hover:decoration-blue-400 transition-colors"
              >
                Kolapo Imam
              </a>
            </span>
            <span className="text-stone-700">·</span>
            <span>© 2026 Mountly. Independent macOS Utility.</span>
          </div>
        </div>
      </footer>
    </div>
  );
}
