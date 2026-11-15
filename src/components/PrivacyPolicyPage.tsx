import type { ReactNode } from 'react';
import {
  ArrowLeft,
  CheckCircle2,
  Download,
  ExternalLink,
  EyeOff,
  FileCode2,
  HardDrive,
  Lock,
  ServerOff,
  ShieldCheck,
  Terminal,
} from 'lucide-react';
import { Accordion } from './Accordion';
import type { AccordionEntry } from './Accordion';
import { AUTHOR_URL, DOWNLOAD_URL, GITHUB_URL, Wordmark } from './Brand';
import { Footer } from './Footer';

interface PrivacyPolicyPageProps {
  onBackToHome: () => void;
}

export const PRIVACY_FAQS: AccordionEntry[] = [
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

const PRINCIPLES = [
  {
    title: 'Zero Network Activity',
    body: 'No telemetry beacons, analytics pings, or background server calls. Mountly functions completely severed from the internet.',
    icon: ServerOff,
    card: 'bg-cobalt-tint',
    tile: 'bg-cobalt text-white',
  },
  {
    title: 'Apple DiskArbitration',
    body: 'Mounting and partition detection rely directly on official Apple frameworks without unsafe kernel modifications.',
    icon: HardDrive,
    card: 'bg-mint-tint',
    tile: 'bg-mint text-white',
  },
  {
    title: 'Zero File Inspection',
    body: 'Mountly never catalogs, reads, or indexes contents on your storage devices. Discovered volumes open directly in Finder.',
    icon: Lock,
    card: 'bg-sun-tint',
    tile: 'bg-sun text-ink',
  },
];

const NOT_COLLECTED = [
  'No user identities or account info',
  'No unique hardware identifiers',
  'No session logs or launch counters',
  'No IP addresses or location data',
];

function PolicySection({
  number,
  badge,
  title,
  children,
}: {
  number: string;
  badge: string;
  title: string;
  children: ReactNode;
}) {
  return (
    <section className="grid gap-4 border-t border-line pt-10 first:border-t-0 first:pt-0 md:grid-cols-[180px_1fr] md:gap-10">
      <div>
        <span className={`inline-flex rounded-lg px-2.5 py-1 font-mono text-[13px] font-medium ${badge}`}>{number}</span>
      </div>
      <div className="space-y-4">
        <h2 className="font-display text-2xl font-bold tracking-[-0.02em] sm:text-[28px]">{title}</h2>
        {children}
      </div>
    </section>
  );
}

export function PrivacyPolicyPage({ onBackToHome }: PrivacyPolicyPageProps) {
  return (
    <div className="flex min-h-screen flex-col bg-cream text-ink">
      <header className="sticky top-0 z-50 border-b border-line/80 bg-cream/85 backdrop-blur-xl">
        <div className="mx-auto flex h-[76px] max-w-6xl items-center justify-between gap-4 px-5 sm:px-6">
          <a
            href="/"
            onClick={(e) => {
              e.preventDefault();
              onBackToHome();
            }}
            className="flex items-center gap-3 rounded-xl focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt"
          >
            <Wordmark />
            <span className="hidden rounded-full border border-line bg-white px-3 py-1 text-[13px] font-medium text-muted sm:inline">
              Privacy Policy
            </span>
          </a>
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={onBackToHome}
              className="inline-flex min-h-11 items-center gap-2 rounded-full border border-line bg-white px-4 text-[15px] font-medium text-ink hover:bg-cream-2 focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt"
            >
              <ArrowLeft className="h-4 w-4" aria-hidden="true" />
              <span className="hidden sm:inline">Back to Home</span>
              <span className="sm:hidden">Home</span>
            </button>
            <a
              href={DOWNLOAD_URL}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="Download Mountly"
              className="inline-flex min-h-11 items-center gap-2 rounded-full bg-ink px-4 text-[15px] font-semibold text-white hover:bg-black focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt sm:px-5"
            >
              <Download className="h-4 w-4" strokeWidth={2.2} aria-hidden="true" />
              <span className="hidden sm:inline">Download</span>
            </a>
          </div>
        </div>
      </header>

      <main className="flex-1 px-5 pb-20 pt-16 sm:px-6 sm:pt-20">
        <article className="mx-auto max-w-5xl">
          {/* Intro */}
          <div className="max-w-3xl">
            <span className="inline-flex items-center gap-2 rounded-full bg-mint-tint px-3.5 py-1.5 text-[13px] font-semibold text-mint-ink">
              <ShieldCheck className="h-4 w-4" aria-hidden="true" />
              Zero-Telemetry Architecture
            </span>
            <h1 className="mt-6 font-display text-[clamp(44px,6.4vw,84px)] font-extrabold leading-[0.98] tracking-[-0.045em]">
              Privacy{' '}
              <span className="inline-block -rotate-2 rounded-[0.18em] bg-sun px-[0.16em] pb-[0.06em]">Policy</span>
            </h1>
            <p className="mt-7 max-w-2xl text-lg leading-relaxed text-muted sm:text-xl">
              Mountly is designed from first principles to be completely local, private, and transparent. We never track you, collect data, or connect to external servers.
            </p>
            <div className="mt-6 flex flex-wrap items-center gap-x-4 gap-y-2 font-mono text-[13px] text-subtle">
              <span>Effective: September 2026</span>
              <span aria-hidden="true">·</span>
              <span>Universal macOS Utility</span>
              <span aria-hidden="true">·</span>
              <span className="inline-flex items-center gap-1.5 text-mint-ink">
                <CheckCircle2 className="h-4 w-4" aria-hidden="true" /> 100% Offline
              </span>
            </div>
          </div>

          {/* Principles */}
          <div className="mt-14 grid grid-cols-1 gap-4 md:grid-cols-3">
            {PRINCIPLES.map(({ title, body, icon: Icon, card, tile }) => (
              <div key={title} className={`flex flex-col gap-4 rounded-[28px] p-7 ${card}`}>
                <span
                  className={`flex h-12 w-12 items-center justify-center rounded-[14px] shadow-[inset_0_-4px_0_rgba(0,0,0,0.14)] ${tile}`}
                >
                  <Icon className="h-[22px] w-[22px]" strokeWidth={2.1} aria-hidden="true" />
                </span>
                <h2 className="mt-2 font-display text-[22px] font-bold tracking-[-0.02em]">{title}</h2>
                <p className="text-[15px] leading-relaxed text-[#4a463f]">{body}</p>
              </div>
            ))}
          </div>

          {/* Policy body */}
          <div className="mt-16 space-y-10 rounded-[32px] border border-line bg-white p-7 sm:p-12">
            <PolicySection number="01" badge="bg-cobalt-tint text-cobalt-ink" title="Information Collection & Storage">
              <p className="text-base leading-relaxed text-muted">
                Mountly does not collect, record, transmit, or monetize any personal information or telemetry data. Specifically:
              </p>
              <ul className="grid grid-cols-1 gap-2.5 sm:grid-cols-2">
                {NOT_COLLECTED.map((item) => (
                  <li
                    key={item}
                    className="flex items-center gap-2.5 rounded-xl border border-line bg-paper px-3.5 py-3 font-mono text-[13px] text-ink"
                  >
                    <EyeOff className="h-4 w-4 shrink-0 text-cobalt" aria-hidden="true" />
                    {item}
                  </li>
                ))}
              </ul>
            </PolicySection>

            <PolicySection number="02" badge="bg-tangerine-tint text-tangerine-ink" title="Drive Management & File Content Isolation">
              <p className="text-base leading-relaxed text-muted">
                When you connect an external USB-C, USB-A, portable SSD, or mechanical hard drive, Mountly inspects only the partition header metadata required to recognize the filesystem type (e.g., NTFS, exFAT, APFS).
              </p>
              <p className="text-base leading-relaxed text-muted">
                At no point does Mountly scan, index, copy, or transmit directory listings or personal documents stored on your drive. All read and write operations are routed through standard macOS filesystem drivers directly to Finder.
              </p>
            </PolicySection>

            <PolicySection number="03" badge="bg-mint-tint text-mint-ink" title="System Permissions & Helper Privileges">
              <p className="text-base leading-relaxed text-muted">
                Mounting non-native external filesystems (such as enabling NTFS write mode) may require administrative disk arbitration authorization via macOS Security prompts.
              </p>
              <div className="flex items-start gap-3 rounded-2xl bg-ink p-5 text-[15px] leading-relaxed text-[#e9e3d6]">
                <Terminal className="mt-0.5 h-5 w-5 shrink-0 text-sun" aria-hidden="true" />
                <span>
                  Privileges are confined strictly to standard disk mount/unmount operations and safe volume synchronization. Mountly never requests root access to personal user folders or keychain items.
                </span>
              </div>
            </PolicySection>

            <PolicySection number="04" badge="bg-sun-tint text-sun-ink" title="Website & Download Integrity">
              <p className="text-base leading-relaxed text-muted">
                This website is delivered as static HTML, JavaScript, and CSS. No advertising networks, marketing trackers, or tracking cookies are employed on this domain. Downloads are verified and hosted directly without third-party ad-wrappers or data capture intermediaries.
              </p>
            </PolicySection>

            <PolicySection number="05" badge="bg-lilac-tint text-[#5240c9]" title="Open Source Verification & Auditing">
              <p className="text-base leading-relaxed text-muted">
                Trust is established through verifiability. The complete source code of Mountly is maintained openly on GitHub. Anyone can audit the network entitlements, inspect disk helpers, and compile the code independently.
              </p>
              <div className="flex flex-wrap gap-3 pt-1">
                <a
                  href={GITHUB_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex min-h-11 items-center gap-2 rounded-full bg-ink px-5 text-sm font-semibold text-white hover:bg-black"
                >
                  <FileCode2 className="h-4 w-4 text-sun" aria-hidden="true" />
                  Inspect Source on GitHub
                  <ExternalLink className="h-3.5 w-3.5 text-white/60" aria-hidden="true" />
                </a>
                <a
                  href={AUTHOR_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex min-h-11 items-center gap-2 rounded-full border border-line-2 bg-white px-5 text-sm font-semibold text-ink hover:bg-cream-2"
                >
                  Developer Portfolio
                  <ExternalLink className="h-3.5 w-3.5 text-subtle" aria-hidden="true" />
                </a>
              </div>
            </PolicySection>
          </div>

          {/* Privacy FAQ */}
          <div className="mt-20 flex flex-col gap-10 lg:flex-row">
            <div className="lg:w-[36%] lg:shrink-0">
              <h2 className="font-display text-[clamp(32px,4vw,48px)] font-extrabold leading-[1.04] tracking-[-0.035em]">
                Privacy Questions &amp; Answers
              </h2>
            </div>
            <div className="min-w-0 flex-1">
              <Accordion items={PRIVACY_FAQS} defaultOpen={0} size="md" />
            </div>
          </div>

          {/* Return card */}
          <div className="relative mt-20 flex flex-col items-center justify-between gap-6 overflow-hidden rounded-[32px] bg-cobalt p-8 text-center text-white sm:flex-row sm:p-10 sm:text-left">
            <div aria-hidden="true" className="dot-grid absolute inset-0" />
            <div className="relative">
              <h2 className="font-display text-2xl font-bold tracking-[-0.02em] sm:text-3xl">
                Ready to return to the application?
              </h2>
              <p className="mt-2 text-base text-[#e3e8ff]">
                Explore supported filesystems and download Mountly for macOS.
              </p>
            </div>
            <div className="relative flex shrink-0 flex-wrap items-center justify-center gap-3">
              <button
                type="button"
                onClick={onBackToHome}
                className="inline-flex min-h-12 items-center gap-2 rounded-full border-[1.5px] border-white/55 px-5 text-[15px] font-semibold text-white hover:bg-white/10"
              >
                <ArrowLeft className="h-4 w-4" aria-hidden="true" />
                Back to Home
              </button>
              <a
                href={DOWNLOAD_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex min-h-12 items-center gap-2 rounded-full bg-cream px-6 text-[15px] font-semibold text-ink shadow-[0_5px_0_var(--color-ink)] hover:bg-white"
              >
                <Download className="h-4 w-4" strokeWidth={2.2} aria-hidden="true" />
                Download
              </a>
            </div>
          </div>
        </article>
      </main>

      <Footer onOpenPrivacy={() => window.scrollTo({ top: 0, behavior: 'smooth' })} />
    </div>
  );
}
