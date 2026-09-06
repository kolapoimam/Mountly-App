import { Shield } from 'lucide-react';

export function TrustStatement() {
  return (
    <section id="trust-statement" className="py-12 border-y border-stone-200 dark:border-stone-800/80 bg-stone-100/60 dark:bg-stone-900/30">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 text-center space-y-4">
        <div className="inline-flex items-center justify-center h-10 w-10 rounded-full bg-blue-100 dark:bg-blue-950/60 border border-blue-200 dark:border-blue-800/60 text-blue-600 dark:text-blue-400 mb-1">
          <Shield className="h-5 w-5" aria-hidden="true" />
        </div>
        <h2 className="text-2xl sm:text-3xl font-bold tracking-tight text-stone-900 dark:text-white">
          Your drive. Your files. No unnecessary formatting.
        </h2>
        <p className="text-base sm:text-lg text-stone-600 dark:text-stone-300 max-w-2xl mx-auto leading-relaxed">
          Mountly is designed to help you access compatible external filesystems without asking you to erase or reformat the drive simply because you're using a Mac.
        </p>
      </div>
    </section>
  );
}
