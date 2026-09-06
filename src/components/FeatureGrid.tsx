import {
  Folder,
  Unplug,
  HardDrive,
  ArrowUpDown,
} from 'lucide-react';

export function FeatureGrid() {
  const features = [
    {
      title: 'NTFS Read & Write',
      description:
        'Enable full read and write access on NTFS formatted external drives without terminal commands or reformatting.',
      icon: ArrowUpDown,
    },
    {
      title: 'Finder Integration',
      description:
        'Discovered volumes appear right in macOS Finder so you can browse, copy, and organize files naturally.',
      icon: Folder,
    },
    {
      title: 'Safe Volume Operations',
      description:
        'Protected mounting routines and safe eject ensure existing partition journals remain undamaged.',
      icon: Unplug,
    },
    {
      title: 'Universal Hardware Support',
      description:
        'Compatible with any external enclosure — USB-C, USB-A, portable SSDs, mechanical HDDs, and flash media.',
      icon: HardDrive,
    },
  ];

  return (
    <section id="features" className="py-20 md:py-28 border-t border-stone-800/80 bg-stone-950">
      <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-2xl mx-auto text-center mb-14 space-y-3">
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">
            Everything you need. Nothing you don't.
          </h2>
          <p className="text-base text-stone-400">
            A lightweight, focused utility designed to make external filesystems seamless on Mac.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {features.map((feature) => {
            const IconComp = feature.icon;
            return (
              <div
                key={feature.title}
                className="rounded-2xl border border-stone-800/90 bg-stone-900/40 p-6 sm:p-7 flex flex-col justify-between hover:border-stone-700 transition-all group"
              >
                <div>
                  <div className="h-10 w-10 rounded-xl bg-stone-800/80 border border-stone-700/60 flex items-center justify-center text-blue-400 mb-5 group-hover:scale-105 transition-transform">
                    <IconComp className="h-5 w-5" aria-hidden="true" />
                  </div>
                  <h3 className="text-base font-bold text-white mb-2">
                    {feature.title}
                  </h3>
                  <p className="text-sm text-stone-400 leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
