import { CheckCircle2, Cpu, HardDrive } from 'lucide-react';
import type { FilesystemInfo } from '../types';
import { SectionEyebrow } from './Brand';

interface FsCard extends FilesystemInfo {
  tile: string;
}

const FILESYSTEMS: FsCard[] = [
  {
    name: 'NTFS',
    badge: 'Supported',
    detail: 'Read & Write',
    description: 'Windows volumes mounted with full read/write support enabled.',
    writeSupported: true,
    tile: 'bg-cobalt text-white',
  },
  {
    name: 'exFAT',
    badge: 'Native',
    detail: 'Native macOS',
    description: 'Cross-platform standard supported natively by macOS out of the box.',
    writeSupported: true,
    tile: 'bg-tangerine text-white',
  },
  {
    name: 'APFS',
    badge: 'Native',
    detail: 'Native macOS',
    description: 'Apple File System standard for modern macOS media.',
    writeSupported: true,
    tile: 'bg-lilac text-white',
  },
  {
    name: 'FAT32',
    badge: 'Native',
    detail: 'Native macOS',
    description: 'Universal legacy format supported natively by macOS.',
    writeSupported: true,
    tile: 'bg-sun text-ink',
  },
  {
    name: 'HFS+',
    badge: 'Native',
    detail: 'Native macOS',
    description: 'Mac OS Extended standard supported natively by macOS.',
    writeSupported: true,
    tile: 'bg-berry text-white',
  },
  {
    name: 'EXT4',
    badge: 'Limited',
    detail: 'Read Only',
    description: 'Linux standard filesystem with read support.',
    writeSupported: false,
    tile: 'bg-mint text-white',
  },
];

const BADGE: Record<string, string> = {
  Supported: 'bg-cobalt-tint text-cobalt-ink',
  Native: 'bg-mint-tint text-mint-ink',
  Limited: 'bg-sun-tint text-sun-ink',
  'Coming later': 'bg-cream-2 text-subtle',
};

const DETAIL: Record<string, string> = {
  Supported: 'text-cobalt-ink',
  Native: 'text-mint-ink',
  Limited: 'text-tangerine-ink',
  'Coming later': 'text-subtle',
};

export function CompatibilitySection() {
  return (
    <section id="compatibility" className="px-5 pb-16 pt-24 sm:px-6 md:pt-28">
      <div className="mx-auto max-w-6xl">
        <div className="mb-12 flex flex-wrap items-end justify-between gap-6">
          <div className="max-w-[640px]">
            <SectionEyebrow index="02" label="COMPATIBILITY" tone="text-cobalt-ink" />
            <h2 className="font-display text-[clamp(36px,4.6vw,60px)] font-extrabold leading-[1.02] tracking-[-0.035em]">
              Built for your filesystems and drives.
            </h2>
          </div>
          <p className="max-w-[380px] text-[17px] leading-relaxed text-muted">
            Mountly handles supported external filesystems while respecting native macOS operations.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {FILESYSTEMS.map((fs) => (
            <article
              key={fs.name}
              className="group flex flex-col gap-3.5 rounded-[22px] border border-line bg-white p-6 transition-all hover:-translate-y-1 hover:shadow-[0_18px_40px_-24px_rgba(27,26,23,0.35)]"
            >
              <div className="flex items-center justify-between">
                <span
                  className={`flex h-[52px] w-[52px] items-center justify-center rounded-[15px] shadow-[inset_0_-4px_0_rgba(0,0,0,0.14)] ${fs.tile}`}
                >
                  <HardDrive className="h-[22px] w-[22px]" strokeWidth={2.1} aria-hidden="true" />
                </span>
                <span className={`rounded-full px-3 py-1 text-xs font-semibold ${BADGE[fs.badge]}`}>{fs.badge}</span>
              </div>
              <h3 className="mt-1 font-display text-[26px] font-bold tracking-[-0.02em]">{fs.name}</h3>
              <p className="flex-1 text-[15px] leading-relaxed text-muted">{fs.description}</p>
              <div className="flex justify-between border-t border-dashed border-line-2 pt-3.5 font-mono text-xs">
                <span className="text-subtle">Access mode</span>
                <span className={`font-medium ${DETAIL[fs.badge]}`}>{fs.detail}</span>
              </div>
            </article>
          ))}
        </div>

        <div className="mt-5 flex flex-wrap items-center justify-between gap-4 rounded-[22px] bg-ink px-6 py-5 text-white sm:px-7">
          <div className="flex items-center gap-4">
            <span className="flex h-12 w-12 shrink-0 items-center justify-center rounded-[14px] bg-sun text-ink">
              <Cpu className="h-[22px] w-[22px]" strokeWidth={2} aria-hidden="true" />
            </span>
            <div>
              <p className="font-display text-[19px] font-bold">Apple Silicon &amp; Intel Universal Binary</p>
              <p className="mt-0.5 text-sm text-[#cfc8ba]">
                Optimized for M1/M2/M3/M4 &amp; Intel 64-bit Macs running macOS 13 Ventura or newer.
              </p>
            </div>
          </div>
          <span className="inline-flex items-center gap-2 rounded-full bg-white/10 px-3.5 py-2 font-mono text-[13px] text-[#9fe3c2]">
            <CheckCircle2 className="h-[15px] w-[15px]" aria-hidden="true" />
            AppKit Native
          </span>
        </div>
      </div>
    </section>
  );
}
