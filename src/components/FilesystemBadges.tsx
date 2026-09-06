import type { FilesystemInfo } from '../types';

export function FilesystemBadges() {
  const filesystems: FilesystemInfo[] = [
    {
      name: 'NTFS',
      badge: 'Supported',
      detail: 'Read & Write',
      description: 'Mounts Windows-formatted volumes with full read and write functionality enabled.',
      writeSupported: true,
    },
    {
      name: 'exFAT',
      badge: 'Native',
      detail: 'Native macOS support',
      description: 'Fully recognized and handled natively by macOS kernel and Finder.',
      writeSupported: true,
    },
    {
      name: 'APFS',
      badge: 'Native',
      detail: 'Native macOS support',
      description: 'Apple File System. Native standard for modern Apple internal and external media.',
      writeSupported: true,
    },
    {
      name: 'HFS+',
      badge: 'Native',
      detail: 'Native macOS support',
      description: 'Mac OS Extended. Full native read and write capability on all modern macOS releases.',
      writeSupported: true,
    },
    {
      name: 'FAT32',
      badge: 'Native',
      detail: 'Native macOS support',
      description: 'Legacy cross-platform standard. Fully supported natively by macOS out of the box.',
      writeSupported: true,
    },
    {
      name: 'EXT4',
      badge: 'Limited',
      detail: 'Limited / expanding support',
      description: 'Linux standard filesystem. Read access supported; experimental write routines under testing.',
      writeSupported: false,
    },
  ];

  return (
    <section id="compatibility" className="py-20 md:py-28 border-t border-stone-200 dark:border-stone-800/80 bg-stone-50 dark:bg-stone-950">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl mb-14">
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-stone-900 dark:text-white mb-3">
            Built for more than one filesystem.
          </h2>
          <p className="text-base text-stone-600 dark:text-stone-400">
            Mountly clarifies exactly which filesystems require driver assistance and which operate through native macOS subsystems.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {filesystems.map((fs) => {
            const isNative = fs.badge === 'Native';
            const isSupported = fs.badge === 'Supported';

            return (
              <div
                key={fs.name}
                className="rounded-2xl border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900/40 p-6 flex flex-col justify-between hover:border-stone-300 dark:hover:border-stone-700 shadow-sm dark:shadow-none transition-all"
              >
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="font-mono text-xl font-bold text-stone-900 dark:text-white tracking-tight">
                      {fs.name}
                    </h3>
                    <span
                      className={`text-xs font-semibold px-2.5 py-0.5 rounded-full border ${
                        isSupported
                          ? 'bg-blue-100 text-blue-800 dark:bg-blue-950/80 dark:text-blue-300 border-blue-200 dark:border-blue-800/60'
                          : isNative
                          ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800/50'
                          : 'bg-stone-100 text-stone-700 dark:bg-stone-800 dark:text-stone-300 border-stone-200 dark:border-stone-700'
                      }`}
                    >
                      {fs.badge}
                    </span>
                  </div>

                  <p className="text-xs font-semibold text-stone-800 dark:text-stone-300 mb-2 font-mono">
                    {fs.detail}
                  </p>

                  <p className="text-xs text-stone-600 dark:text-stone-400 leading-relaxed">
                    {fs.description}
                  </p>
                </div>

                <div className="pt-5 mt-5 border-t border-stone-100 dark:border-stone-800/60 flex items-center justify-between text-[11px]">
                  <span className="text-stone-500 dark:text-stone-500">Write access:</span>
                  <span
                    className={`font-semibold ${
                      fs.writeSupported
                        ? 'text-emerald-700 dark:text-emerald-400'
                        : 'text-amber-700 dark:text-amber-400'
                    }`}
                  >
                    {fs.writeSupported ? 'Verified' : 'Read only'}
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
