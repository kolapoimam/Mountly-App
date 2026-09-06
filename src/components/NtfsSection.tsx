import { CheckCircle2, HardDrive, ShieldCheck, Terminal, ArrowRight } from 'lucide-react';

export function NtfsSection() {
  return (
    <section id="ntfs" className="py-20 md:py-28 border-t border-stone-200 dark:border-stone-800/80 bg-stone-100/40 dark:bg-stone-900/20">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          {/* Left Text */}
          <div className="lg:col-span-6 space-y-6">
            <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded-md text-xs font-mono font-medium bg-blue-100 dark:bg-blue-950/80 text-blue-700 dark:text-blue-300 border border-blue-200 dark:border-blue-800/60">
              Primary Use Case
            </div>
            <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-stone-900 dark:text-white">
              NTFS, without the usual hassle.
            </h2>
            <p className="text-base sm:text-lg text-stone-600 dark:text-stone-300 leading-relaxed font-normal">
              macOS can read NTFS drives, but native write support is limited. Mountly provides a simpler interface for supported NTFS read/write workflows without requiring you to reformat a drive just to use it with your Mac.
            </p>

            <div className="pt-2 space-y-3">
              <div className="flex items-start gap-3">
                <div className="h-5 w-5 rounded-full bg-blue-100 dark:bg-blue-950/60 border border-blue-200 dark:border-blue-800/50 flex items-center justify-center text-blue-600 dark:text-blue-400 mt-0.5 shrink-0">
                  <CheckCircle2 className="h-3.5 w-3.5" />
                </div>
                <p className="text-sm text-stone-600 dark:text-stone-300">
                  <strong className="text-stone-900 dark:text-white font-semibold">Preserve Windows file structures</strong> — keep all existing folders, permissions, and directory structures intact.
                </p>
              </div>
              <div className="flex items-start gap-3">
                <div className="h-5 w-5 rounded-full bg-blue-100 dark:bg-blue-950/60 border border-blue-200 dark:border-blue-800/50 flex items-center justify-center text-blue-600 dark:text-blue-400 mt-0.5 shrink-0">
                  <CheckCircle2 className="h-3.5 w-3.5" />
                </div>
                <p className="text-sm text-stone-600 dark:text-stone-300">
                  <strong className="text-stone-900 dark:text-white font-semibold">No terminal scripts required</strong> — handles driver mounting behind a clean native macOS interface.
                </p>
              </div>
            </div>
          </div>

          {/* Right UI Visual */}
          <div className="lg:col-span-6">
            <div className="rounded-2xl border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900/90 p-6 sm:p-7 shadow-xl shadow-stone-900/5 dark:shadow-black/40 space-y-5">
              {/* Header */}
              <div className="flex items-center justify-between pb-4 border-b border-stone-100 dark:border-stone-800">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-xl bg-stone-100 dark:bg-stone-800 flex items-center justify-center text-blue-600 dark:text-blue-400 border border-stone-200 dark:border-stone-700/60">
                    <HardDrive className="h-5 w-5" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-stone-900 dark:text-white text-base">NTFS Volume</span>
                      <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-blue-100 dark:bg-blue-950 text-blue-700 dark:text-blue-300 border border-blue-200 dark:border-blue-800/60 font-medium">
                        NTFS
                      </span>
                    </div>
                    <span className="text-xs text-stone-500 dark:text-stone-400">Connected via USB 3.2</span>
                  </div>
                </div>

                <div className="text-right">
                  <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-700 dark:text-emerald-400 bg-emerald-100 dark:bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-200 dark:border-emerald-800/40">
                    <CheckCircle2 className="h-3 w-3" />
                    Read & Write
                  </span>
                </div>
              </div>

              {/* Comparison table */}
              <div className="grid grid-cols-2 gap-3 text-xs">
                <div className="p-3 rounded-xl bg-stone-50 dark:bg-stone-950/60 border border-stone-200 dark:border-stone-800/60 space-y-1">
                  <span className="text-[10px] font-medium text-stone-500 uppercase tracking-wider">Default macOS</span>
                  <div className="flex items-center gap-1.5 text-stone-700 dark:text-stone-300 font-semibold">
                    <span className="h-1.5 w-1.5 rounded-full bg-amber-500" />
                    <span>Read Only</span>
                  </div>
                  <p className="text-[11px] text-stone-500 leading-tight">Cannot copy, delete, or rename files</p>
                </div>

                <div className="p-3 rounded-xl bg-blue-50 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-800/40 space-y-1">
                  <span className="text-[10px] font-medium text-blue-700 dark:text-blue-300 uppercase tracking-wider font-semibold">With Mountly</span>
                  <div className="flex items-center gap-1.5 text-blue-900 dark:text-blue-200 font-bold">
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                    <span>Full Read & Write</span>
                  </div>
                  <p className="text-[11px] text-stone-600 dark:text-stone-300 leading-tight">Create, edit, organize transparently</p>
                </div>
              </div>

              {/* Status footer inside card */}
              <div className="pt-2 border-t border-stone-100 dark:border-stone-800/70 flex items-center justify-between text-xs text-stone-500 dark:text-stone-400">
                <div className="flex items-center gap-1.5">
                  <ShieldCheck className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400" />
                  <span>Journal Verified</span>
                </div>
                <span className="font-mono text-[10px]">Driver: mount_ntfs (optimized)</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
