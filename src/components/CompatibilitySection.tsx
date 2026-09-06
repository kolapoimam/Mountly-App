import { CheckCircle2, Laptop } from 'lucide-react';
import type { FilesystemInfo } from '../types';

export function CompatibilitySection() {
  const filesystems: FilesystemInfo[] = [
    {
      name: 'NTFS',
      badge: 'Supported',
      detail: 'Read & Write',
      description: 'Windows volumes mounted with full read/write support enabled.',
      writeSupported: true,
    },
    {
      name: 'exFAT',
      badge: 'Native',
      detail: 'Native macOS',
      description: 'Cross-platform standard supported natively by macOS out of the box.',
      writeSupported: true,
    },
    {
      name: 'APFS',
      badge: 'Native',
      detail: 'Native macOS',
      description: 'Apple File System standard for modern macOS media.',
      writeSupported: true,
    },
    {
      name: 'FAT32',
      badge: 'Native',
      detail: 'Native macOS',
      description: 'Universal legacy format supported natively by macOS.',
      writeSupported: true,
    },
    {
      name: 'HFS+',
      badge: 'Native',
      detail: 'Native macOS',
      description: 'Mac OS Extended standard supported natively by macOS.',
      writeSupported: true,
    },
    {
      name: 'EXT4',
      badge: 'Limited',
      detail: 'Read Only',
      description: 'Linux standard filesystem with read support.',
      writeSupported: false,
    },
  ];

  return (
    <section id="compatibility" className="py-20 md:py-28 border-t border-stone-800/80 bg-stone-900/20">
      <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-2xl mx-auto text-center mb-14 space-y-3">
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">
            Built for your filesystems and drives.
          </h2>
          <p className="text-base text-stone-400">
            Mountly handles supported external filesystems while respecting native macOS operations.
          </p>
        </div>

        {/* Filesystem Matrix */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-10">
          {filesystems.map((fs) => {
            const isSupported = fs.badge === 'Supported';
            const isNative = fs.badge === 'Native';

            return (
              <div
                key={fs.name}
                className="rounded-xl border border-stone-800 bg-stone-900/40 p-5 flex flex-col justify-between hover:border-stone-700 transition-all"
              >
                <div>
                  <div className="flex items-center justify-between mb-2.5">
                    <span className="font-mono text-lg font-bold text-white tracking-tight">
                      {fs.name}
                    </span>
                    <span
                      className={`text-[11px] font-semibold px-2 py-0.5 rounded-md border ${
                        isSupported
                          ? 'bg-blue-950/80 text-blue-300 border-blue-800/60'
                          : isNative
                          ? 'bg-emerald-950/60 text-emerald-300 border-emerald-800/50'
                          : 'bg-stone-800 text-stone-300 border-stone-700'
                      }`}
                    >
                      {fs.badge}
                    </span>
                  </div>
                  <p className="text-xs text-stone-400 leading-relaxed">
                    {fs.description}
                  </p>
                </div>

                <div className="pt-3 mt-3 border-t border-stone-800/60 flex items-center justify-between text-[11px] text-stone-500 font-mono">
                  <span>Access mode</span>
                  <span className={fs.writeSupported ? 'text-emerald-400' : 'text-amber-400'}>
                    {fs.detail}
                  </span>
                </div>
              </div>
            );
          })}
        </div>

        {/* Mac OS & Hardware footnote */}
        <div className="rounded-xl border border-stone-800 bg-stone-900/30 p-4 sm:p-5 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-stone-400">
          <div className="flex items-center gap-3">
            <div className="h-8 w-8 rounded-lg bg-stone-800 border border-stone-700/60 flex items-center justify-center text-blue-400 shrink-0">
              <Laptop className="h-4 w-4" />
            </div>
            <div>
              <span className="font-semibold text-stone-200">Apple Silicon & Intel Universal Binary</span>
              <p className="text-[11px] text-stone-500 mt-0.5">Optimized for M1/M2/M3/M4 & Intel 64-bit Macs running macOS 13 Ventura or newer.</p>
            </div>
          </div>
          <div className="flex items-center gap-2 text-[11px] text-stone-400 font-mono shrink-0">
            <CheckCircle2 className="h-3.5 w-3.5 text-emerald-400" />
            <span>AppKit Native</span>
          </div>
        </div>
      </div>
    </section>
  );
}
