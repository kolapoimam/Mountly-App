import { HardDrive, Layers, Folder } from 'lucide-react';

export function HowItWorks() {
  const steps = [
    {
      step: '01',
      title: 'Connect your drive',
      description: 'Plug your external storage into your Mac.',
      icon: HardDrive,
    },
    {
      step: '02',
      title: 'Mount with Mountly',
      description: 'Mountly detects the filesystem and selects the appropriate supported method.',
      icon: Layers,
    },
    {
      step: '03',
      title: 'Use it normally',
      description: 'Open the drive in Finder and work with your files.',
      icon: Folder,
    },
  ];

  return (
    <section id="how-it-works" className="py-20 md:py-28">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-2xl mx-auto mb-14 space-y-3">
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-stone-900 dark:text-white">
            Connect. Mount. Access.
          </h2>
          <p className="text-sm sm:text-base text-stone-600 dark:text-stone-400">
            A three-step workflow built directly around macOS Finder and native storage standards.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8">
          {steps.map((item) => {
            const IconComponent = item.icon;
            return (
              <div
                key={item.step}
                className="relative rounded-2xl border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900/50 p-6 sm:p-8 flex flex-col justify-between hover:border-stone-300 dark:hover:border-stone-700 shadow-sm dark:shadow-none transition-all"
              >
                <div>
                  <div className="flex items-center justify-between mb-6">
                    <span className="font-mono text-xs font-semibold text-blue-600 dark:text-blue-400 tracking-wider">
                      {item.step}
                    </span>
                    <div className="h-10 w-10 rounded-xl bg-stone-100 dark:bg-stone-800/80 border border-stone-200 dark:border-stone-700/60 flex items-center justify-center text-blue-600 dark:text-blue-400">
                      <IconComponent className="h-5 w-5" aria-hidden="true" />
                    </div>
                  </div>
                  <h3 className="text-lg font-bold text-stone-900 dark:text-white mb-2">
                    {item.title}
                  </h3>
                  <p className="text-sm text-stone-600 dark:text-stone-300 leading-relaxed">
                    {item.description}
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
