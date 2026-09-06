import { ShieldAlert, AlertTriangle, Activity } from 'lucide-react';

export function SafetySection() {
  const points = [
    {
      title: 'No automatic formatting',
      description: 'Mountly should never automatically erase or reformat a drive.',
      icon: ShieldAlert,
    },
    {
      title: 'No silent destructive actions',
      description: 'Operations that could affect user data require explicit user action.',
      icon: AlertTriangle,
    },
    {
      title: 'Clear drive status',
      description: 'Know whether a drive is mounted, read-only, writable, unsupported or needs attention.',
      icon: Activity,
    },
  ];

  return (
    <section id="safety" className="py-20 md:py-28 border-t border-stone-200 dark:border-stone-800/80 bg-stone-100/40 dark:bg-stone-900/20">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl mb-14">
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-stone-900 dark:text-white mb-3">
            Your files come first.
          </h2>
          <p className="text-base sm:text-lg text-stone-600 dark:text-stone-300 leading-relaxed font-normal">
            Mountly is designed around one simple principle: accessing a drive should not mean putting its existing data at unnecessary risk.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {points.map((point) => {
            const IconComponent = point.icon;
            return (
              <div
                key={point.title}
                className="rounded-2xl border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900/50 p-6 sm:p-7 flex flex-col justify-between hover:border-stone-300 dark:hover:border-stone-700 shadow-sm dark:shadow-none transition-all"
              >
                <div>
                  <div className="h-10 w-10 rounded-xl bg-stone-100 dark:bg-stone-800 border border-stone-200 dark:border-stone-700/60 flex items-center justify-center text-blue-600 dark:text-blue-400 mb-5">
                    <IconComponent className="h-5 w-5" aria-hidden="true" />
                  </div>
                  <h3 className="text-base font-bold text-stone-900 dark:text-white mb-2">
                    {point.title}
                  </h3>
                  <p className="text-sm text-stone-600 dark:text-stone-300 leading-relaxed">
                    {point.description}
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
