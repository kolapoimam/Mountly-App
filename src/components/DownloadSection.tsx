import { Download, ExternalLink, ShieldCheck } from 'lucide-react';

interface DownloadSectionProps {
  onOpenDownload: () => void;
  onOpenDonate?: () => void;
}

export function DownloadSection({
  onOpenDownload,
}: DownloadSectionProps) {
  return (
    <section id="download" className="py-20 md:py-28 border-t border-stone-800/80 bg-stone-900/30">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 text-center space-y-6">
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-extrabold tracking-tight text-white">
          Give your external drives a better way to work with Mac.
        </h2>

        <p className="text-base sm:text-lg text-stone-300 max-w-2xl mx-auto leading-relaxed">
          Download Mountly and get started with supported external filesystems.
        </p>

        {/* Primary and Secondary CTA */}
        <div className="pt-2 flex flex-col sm:flex-row items-center justify-center gap-3">
          <button
            type="button"
            id="download-section-primary-btn"
            onClick={onOpenDownload}
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-6 py-3.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-semibold text-sm shadow-md shadow-blue-900/20 hover:shadow-blue-800/30 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 active:scale-[0.98]"
          >
            <Download className="h-4 w-4" aria-hidden="true" />
            <span>Download Mountly</span>
          </button>

          <a
            href="https://github.com/kolapoimam/mountly"
            target="_blank"
            rel="noopener noreferrer"
            id="download-section-github-btn"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-3.5 rounded-xl border border-stone-800 hover:border-stone-700 bg-stone-900/70 hover:bg-stone-800 text-stone-300 hover:text-white font-medium text-sm transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
          >
            <ExternalLink className="h-4 w-4 text-stone-400" aria-hidden="true" />
            <span>View on GitHub</span>
          </a>
        </div>

        {/* Version metadata */}
        <div className="pt-2 text-xs text-stone-400 space-y-1">
          <p className="font-semibold text-stone-300">Mountly 1.0.0</p>
          <p className="text-stone-500">
            macOS 13.0 or later · Apple Silicon & Intel 64-bit · Free & Open Source
          </p>
        </div>
      </div>
    </section>
  );
}
