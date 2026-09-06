import { useState } from 'react';
import {
  HardDrive,
  ArrowLeft,
  ShieldCheck,
  Lock,
  EyeOff,
  ServerOff,
  ExternalLink,
  Download,
  Terminal,
  ChevronDown,
  CheckCircle2,
  FileCode2,
} from 'lucide-react';

interface PrivacyPolicyPageProps {
  onBackToHome: () => void;
}

export function PrivacyPolicyPage({ onBackToHome }: PrivacyPolicyPageProps) {
  const downloadUrl = 'https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing';
  const donateUrl = 'https://paystack.shop/pay/pmbuddy';

  const [openFaq, setOpenFaq] = useState<number | null>(0);

  const toggleFaq = (idx: number) => {
    setOpenFaq((prev) => (prev === idx ? null : idx));
  };

  const privacyFaqs = [
    {
      q: 'Does Mountly ever transmit disk names or serial numbers?',
      a: 'No. Device descriptors, volume labels, and filesystem partition tables are queried strictly in-memory using Apple DiskArbitration and are discarded upon eject or app termination.',
    },
    {
      q: 'Does Mountly send crash reports or analytics?',
      a: 'No. Mountly contains zero crash analytics SDKs, zero telemetry probes, and no marketing tags. If an error occurs during disk mounting, diagnostic messages are sent solely to your local macOS Console.',
    },
    {
      q: 'Can Mountly read or index files on my mounted drives?',
      a: 'No. Mountly operates as a mounting controller, not a file indexer. Once a drive is mounted, your file operations are handled directly by macOS Finder and your chosen applications.',
    },
    {
      q: 'How can I verify these privacy claims?',
      a: 'Mountly is open source. You can inspect the source code, examine the project’s network entitlements, and build the binary directly from GitHub.',
    },
  ];

  return (
    <div className="min-h-screen bg-stone-950 text-stone-100 flex flex-col justify-between selection:bg-blue-600 selection:text-white">
      {/* Top Bar / Header */}
      <header className="border-b border-stone-800/80 bg-stone-950/80 backdrop-blur-md sticky top-0 z-40">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <button
            type="button"
            onClick={onBackToHome}
            className="flex items-center gap-2.5 text-stone-300 hover:text-white transition-colors group cursor-pointer"
          >
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-stone-900 border border-stone-800 text-blue-400 group-hover:border-stone-700 transition-colors">
              <HardDrive className="h-3.5 w-3.5" aria-hidden="true" />
            </div>
            <span className="font-bold text-white tracking-tight text-sm">
              Mountly
            </span>
            <span className="text-stone-600 text-xs hidden sm:inline">/</span>
            <span className="text-xs text-stone-400 font-medium hidden sm:inline">Privacy Policy</span>
          </button>

          <div className="flex items-center gap-2 sm:gap-3">
            <a
              href={downloadUrl}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Download Mountly"
              title="Download Mountly"
              className="inline-flex items-center justify-center gap-1.5 h-8 px-2.5 sm:px-4 rounded-full text-xs font-semibold bg-blue-600 hover:bg-blue-500 text-white transition-all shadow-sm focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-400"
            >
              <Download className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">Download</span>
            </a>

            <button
              type="button"
              onClick={onBackToHome}
              className="inline-flex items-center gap-1.5 text-xs text-stone-400 hover:text-white h-8 px-3 rounded-full border border-stone-800 hover:bg-stone-900 transition-colors cursor-pointer"
            >
              <ArrowLeft className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">Back to Home</span>
              <span className="sm:hidden">Home</span>
            </button>
          </div>
        </div>
      </header>

      {/* Main Privacy Policy Content */}
      <main className="flex-1 py-12 sm:py-20">
        <article className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 space-y-16">
          {/* Hero Header */}
          <div className="space-y-4 text-center sm:text-left">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-medium bg-blue-950/60 border border-blue-800/60 text-blue-300">
              <ShieldCheck className="h-3.5 w-3.5 text-blue-400" />
              <span>Zero-Telemetry Architecture</span>
            </div>
            <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
              Privacy Policy
            </h1>
            <p className="text-base sm:text-lg text-stone-400 max-w-2xl leading-relaxed">
              Mountly is designed from first principles to be completely local, private, and transparent. We never track you, collect data, or connect to external servers.
            </p>
            <div className="pt-1 flex flex-wrap items-center justify-center sm:justify-start gap-4 text-xs text-stone-500 font-mono">
              <span>Effective: September 2026</span>
              <span>·</span>
              <span>Universal macOS Utility</span>
              <span>·</span>
              <span className="text-emerald-400 flex items-center gap-1">
                <CheckCircle2 className="h-3.5 w-3.5" /> 100% Offline
              </span>
            </div>
          </div>

          {/* 3 Core Principles Bento Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            <div className="rounded-2xl border border-stone-800 bg-stone-900/40 p-6 space-y-3 hover:border-stone-700 transition-all">
              <div className="h-9 w-9 rounded-xl bg-stone-800/90 border border-stone-700/70 flex items-center justify-center text-blue-400">
                <ServerOff className="h-4 w-4" />
              </div>
              <h2 className="text-sm font-bold text-white tracking-tight">
                Zero Network Activity
              </h2>
              <p className="text-xs text-stone-400 leading-relaxed">
                No telemetry beacons, analytics pings, or background server calls. Mountly functions completely severed from the internet.
              </p>
            </div>

            <div className="rounded-2xl border border-stone-800 bg-stone-900/40 p-6 space-y-3 hover:border-stone-700 transition-all">
              <div className="h-9 w-9 rounded-xl bg-stone-800/90 border border-stone-700/70 flex items-center justify-center text-emerald-400">
                <HardDrive className="h-4 w-4" />
              </div>
              <h2 className="text-sm font-bold text-white tracking-tight">
                Apple DiskArbitration
              </h2>
              <p className="text-xs text-stone-400 leading-relaxed">
                Mounting and partition detection rely directly on official Apple frameworks without unsafe kernel modifications.
              </p>
            </div>

            <div className="rounded-2xl border border-stone-800 bg-stone-900/40 p-6 space-y-3 hover:border-stone-700 transition-all">
              <div className="h-9 w-9 rounded-xl bg-stone-800/90 border border-stone-700/70 flex items-center justify-center text-amber-400">
                <Lock className="h-4 w-4" />
              </div>
              <h2 className="text-sm font-bold text-white tracking-tight">
                Zero File Inspection
              </h2>
              <p className="text-xs text-stone-400 leading-relaxed">
                Mountly never catalogs, reads, or indexes contents on your storage devices. Discovered volumes open directly in Finder.
              </p>
            </div>
          </div>

          {/* Detailed Policy Sections */}
          <div className="space-y-12 divide-y divide-stone-800/80">
            {/* Section 1 */}
            <section className="pt-8 first:pt-0 space-y-4">
              <div className="flex items-center gap-3">
                <span className="text-xs font-mono font-bold text-blue-400 px-2 py-0.5 rounded bg-blue-950/60 border border-blue-900/50">
                  01
                </span>
                <h3 className="text-lg font-bold text-white">
                  Information Collection & Storage
                </h3>
              </div>
              <p className="text-sm text-stone-300 leading-relaxed">
                Mountly does not collect, record, transmit, or monetize any personal information or telemetry data. Specifically:
              </p>
              <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs text-stone-400 font-mono">
                <li className="flex items-center gap-2 p-2.5 rounded-lg bg-stone-900/50 border border-stone-800/70">
                  <EyeOff className="h-3.5 w-3.5 text-blue-400 shrink-0" />
                  <span>No user identities or account info</span>
                </li>
                <li className="flex items-center gap-2 p-2.5 rounded-lg bg-stone-900/50 border border-stone-800/70">
                  <EyeOff className="h-3.5 w-3.5 text-blue-400 shrink-0" />
                  <span>No unique hardware identifiers</span>
                </li>
                <li className="flex items-center gap-2 p-2.5 rounded-lg bg-stone-900/50 border border-stone-800/70">
                  <EyeOff className="h-3.5 w-3.5 text-blue-400 shrink-0" />
                  <span>No session logs or launch counters</span>
                </li>
                <li className="flex items-center gap-2 p-2.5 rounded-lg bg-stone-900/50 border border-stone-800/70">
                  <EyeOff className="h-3.5 w-3.5 text-blue-400 shrink-0" />
                  <span>No IP addresses or location data</span>
                </li>
              </ul>
            </section>

            {/* Section 2 */}
            <section className="pt-8 space-y-4">
              <div className="flex items-center gap-3">
                <span className="text-xs font-mono font-bold text-blue-400 px-2 py-0.5 rounded bg-blue-950/60 border border-blue-900/50">
                  02
                </span>
                <h3 className="text-lg font-bold text-white">
                  Drive Management & File Content Isolation
                </h3>
              </div>
              <p className="text-sm text-stone-300 leading-relaxed">
                When you connect an external USB-C, USB-A, portable SSD, or mechanical hard drive, Mountly inspects only the partition header metadata required to recognize the filesystem type (e.g., NTFS, exFAT, APFS).
              </p>
              <p className="text-sm text-stone-300 leading-relaxed">
                At no point does Mountly scan, index, copy, or transmit directory listings or personal documents stored on your drive. All read and write operations are routed through standard macOS filesystem drivers directly to Finder.
              </p>
            </section>

            {/* Section 3 */}
            <section className="pt-8 space-y-4">
              <div className="flex items-center gap-3">
                <span className="text-xs font-mono font-bold text-blue-400 px-2 py-0.5 rounded bg-blue-950/60 border border-blue-900/50">
                  03
                </span>
                <h3 className="text-lg font-bold text-white">
                  System Permissions & Helper Privileges
                </h3>
              </div>
              <p className="text-sm text-stone-300 leading-relaxed">
                Mounting non-native external filesystems (such as enabling NTFS write mode) may require administrative disk arbitration authorization via macOS Security prompts.
              </p>
              <div className="p-4 rounded-xl border border-stone-800 bg-stone-900/30 text-xs text-stone-400 flex items-start gap-3">
                <Terminal className="h-4 w-4 text-blue-400 shrink-0 mt-0.5" />
                <span>
                  Privileges are confined strictly to standard disk mount/unmount operations and safe volume synchronization. Mountly never requests root access to personal user folders or keychain items.
                </span>
              </div>
            </section>

            {/* Section 4 */}
            <section className="pt-8 space-y-4">
              <div className="flex items-center gap-3">
                <span className="text-xs font-mono font-bold text-blue-400 px-2 py-0.5 rounded bg-blue-950/60 border border-blue-900/50">
                  04
                </span>
                <h3 className="text-lg font-bold text-white">
                  Website & Download Integrity
                </h3>
              </div>
              <p className="text-sm text-stone-300 leading-relaxed">
                This website is delivered as static HTML, JavaScript, and CSS. No advertising networks, marketing trackers, or tracking cookies are employed on this domain. Downloads are verified and hosted directly without third-party ad-wrappers or data capture intermediaries.
              </p>
            </section>

            {/* Section 5 */}
            <section className="pt-8 space-y-4">
              <div className="flex items-center gap-3">
                <span className="text-xs font-mono font-bold text-blue-400 px-2 py-0.5 rounded bg-blue-950/60 border border-blue-900/50">
                  05
                </span>
                <h3 className="text-lg font-bold text-white">
                  Open Source Verification & Auditing
                </h3>
              </div>
              <p className="text-sm text-stone-300 leading-relaxed">
                Trust is established through verifiability. The complete source code of Mountly is maintained openly on GitHub. Anyone can audit the network entitlements, inspect disk helpers, and compile the code independently.
              </p>
              <div className="pt-2 flex flex-wrap gap-3">
                <a
                  href="https://github.com/kolapoimam/mountly"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl bg-stone-900 hover:bg-stone-800 border border-stone-800 text-xs font-medium text-stone-200 hover:text-white transition-colors"
                >
                  <FileCode2 className="h-3.5 w-3.5 text-blue-400" />
                  <span>Inspect Source on GitHub</span>
                  <ExternalLink className="h-3 w-3 text-stone-500" />
                </a>
                <a
                  href="https://kolapo.ng"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl bg-stone-900 hover:bg-stone-800 border border-stone-800 text-xs font-medium text-stone-200 hover:text-white transition-colors"
                >
                  <span>Developer Portfolio</span>
                  <ExternalLink className="h-3 w-3 text-stone-500" />
                </a>
              </div>
            </section>
          </div>

          {/* Privacy FAQ Section */}
          <div className="space-y-4 pt-4">
            <h3 className="text-xl font-bold text-white">
              Privacy Questions & Answers
            </h3>
            <div className="divide-y divide-stone-800/80 border-y border-stone-800/80">
              {privacyFaqs.map((item, idx) => {
                const isOpen = openFaq === idx;
                return (
                  <div key={item.q} className="py-4">
                    <button
                      type="button"
                      onClick={() => toggleFaq(idx)}
                      className="flex w-full items-center justify-between text-left focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 rounded py-1 cursor-pointer"
                    >
                      <span className="text-sm font-semibold text-stone-200 pr-4">
                        {item.q}
                      </span>
                      <ChevronDown
                        className={`h-4 w-4 text-stone-400 transition-transform duration-200 shrink-0 ${
                          isOpen ? 'rotate-180 text-blue-400' : ''
                        }`}
                      />
                    </button>
                    {isOpen && (
                      <div className="mt-2 text-xs sm:text-sm text-stone-400 leading-relaxed pr-6 animate-in fade-in duration-150">
                        {item.a}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>

          {/* Bottom Card Action */}
          <div className="rounded-2xl border border-stone-800 bg-stone-900/40 p-6 sm:p-8 flex flex-col sm:flex-row items-center justify-between gap-6 text-center sm:text-left">
            <div className="space-y-1">
              <h3 className="text-base font-bold text-white">
                Ready to return to the application?
              </h3>
              <p className="text-xs text-stone-400">
                Explore supported filesystems and download Mountly for macOS.
              </p>
            </div>
            <div className="flex items-center gap-3 shrink-0">
              <button
                type="button"
                onClick={onBackToHome}
                className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full border border-stone-700 bg-stone-900 hover:bg-stone-800 text-stone-200 text-xs font-medium transition-colors cursor-pointer"
              >
                <ArrowLeft className="h-3.5 w-3.5" />
                <span>Back to Home</span>
              </button>
              <a
                href={downloadUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold shadow-sm transition-all"
              >
                <Download className="h-3.5 w-3.5" />
                <span>Download</span>
              </a>
            </div>
          </div>
        </article>
      </main>

      {/* Connected Footer without divider line, centered on mobile */}
      <footer className="border-t border-stone-800/80 bg-stone-950 text-stone-400 py-10">
        <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8 text-center md:text-left">
          <div className="flex flex-wrap items-center justify-center md:justify-start gap-x-3 gap-y-1 text-xs text-stone-500">
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
