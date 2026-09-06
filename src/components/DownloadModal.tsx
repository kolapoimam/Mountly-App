import { useState } from 'react';
import { X, Download, ShieldCheck, Copy, Check } from 'lucide-react';

interface DownloadModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function DownloadModal({ isOpen, onClose }: DownloadModalProps) {
  const [copied, setCopied] = useState(false);
  const [downloadStarted, setDownloadStarted] = useState(false);

  if (!isOpen) return null;

  const checksum = 'd8c11e74a875a6104bc5bf3e284dc821a7df8448eb3a493a743a4e98f0607198';

  const handleCopyChecksum = () => {
    navigator.clipboard.writeText(checksum);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownload = () => {
    setDownloadStarted(true);
    const releaseUrl = 'https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing';
    const link = document.createElement('a');
    link.href = releaseUrl;
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="download-modal-title"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 dark:bg-black/80 backdrop-blur-sm animate-in fade-in duration-200"
    >
      <div className="relative w-full max-w-lg rounded-2xl border border-stone-200 dark:border-stone-800 bg-white dark:bg-stone-900 p-6 sm:p-7 shadow-2xl text-stone-900 dark:text-stone-100">
        <button
          type="button"
          onClick={onClose}
          aria-label="Close dialog"
          className="absolute top-4 right-4 p-1.5 rounded-lg text-stone-400 hover:text-stone-700 dark:hover:text-white hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
        >
          <X className="h-4 w-4" />
        </button>

        <div className="space-y-4">
          <div>
            <span className="text-[11px] font-mono font-medium text-blue-600 dark:text-blue-400 uppercase tracking-wider">
              Release 1.0.0
            </span>
            <h3 id="download-modal-title" className="text-xl font-bold text-stone-900 dark:text-white mt-0.5">
              Download Mountly for Mac
            </h3>
            <p className="text-xs text-stone-600 dark:text-stone-400 mt-1">
              Universal binary compatible with Apple Silicon (M1/M2/M3/M4) and Intel 64-bit.
            </p>
          </div>

          {/* Download spec block */}
          <div className="rounded-xl bg-stone-50 dark:bg-stone-950/70 border border-stone-200 dark:border-stone-800/80 p-3.5 space-y-2 text-xs">
            <div className="flex justify-between py-1 border-b border-stone-200 dark:border-stone-800/60">
              <span className="text-stone-500 dark:text-stone-400">File format</span>
              <span className="font-mono text-stone-800 dark:text-stone-200">Apple Disk Image (.dmg)</span>
            </div>
            <div className="flex justify-between py-1 border-b border-stone-200 dark:border-stone-800/60">
              <span className="text-stone-500 dark:text-stone-400">Architecture</span>
              <span className="text-stone-800 dark:text-stone-200">Universal (arm64 + x86_64)</span>
            </div>
            <div className="flex justify-between py-1">
              <span className="text-stone-500 dark:text-stone-400">Minimum OS</span>
              <span className="text-stone-800 dark:text-stone-200">macOS 13.0 Ventura or newer</span>
            </div>
          </div>

          {/* Primary Action Button */}
          <button
            type="button"
            id="modal-confirm-download"
            onClick={handleDownload}
            className="w-full py-3 px-4 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-semibold text-sm flex items-center justify-center gap-2 shadow-md shadow-blue-900/20 hover:shadow-blue-800/30 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 active:scale-[0.99]"
          >
            <Download className="h-4 w-4" />
            <span>Download Mountly-1.0.0.dmg</span>
          </button>

          {downloadStarted && (
            <p className="text-xs text-emerald-600 dark:text-emerald-400 text-center flex items-center justify-center gap-1.5">
              <Check className="h-3.5 w-3.5" />
              <span>Download initiated. Check your Downloads folder.</span>
            </p>
          )}

          {/* Checksum verification */}
          <div className="space-y-1.5 pt-1">
            <div className="flex items-center justify-between text-[11px] text-stone-500 dark:text-stone-400">
              <span className="font-medium flex items-center gap-1">
                <ShieldCheck className="h-3.5 w-3.5 text-blue-600 dark:text-blue-400" />
                SHA-256 Checksum
              </span>
              <button
                type="button"
                onClick={handleCopyChecksum}
                className="inline-flex items-center gap-1 text-stone-500 hover:text-stone-900 dark:text-stone-400 dark:hover:text-white transition-colors"
              >
                {copied ? (
                  <>
                    <Check className="h-3 w-3 text-emerald-600 dark:text-emerald-400" />
                    <span className="text-emerald-600 dark:text-emerald-400">Copied</span>
                  </>
                ) : (
                  <>
                    <Copy className="h-3 w-3" />
                    <span>Copy</span>
                  </>
                )}
              </button>
            </div>
            <div className="p-2.5 rounded-lg bg-stone-100 dark:bg-stone-950 font-mono text-[10px] text-stone-700 dark:text-stone-300 break-all select-all border border-stone-200 dark:border-stone-800">
              {checksum}
            </div>
          </div>

          {/* Quick instructions */}
          <div className="pt-2 text-[11px] text-stone-500 dark:text-stone-400 border-t border-stone-200 dark:border-stone-800/80">
            <p className="font-semibold text-stone-800 dark:text-stone-300 mb-1">Installation instructions:</p>
            <ol className="list-decimal list-inside space-y-0.5 text-stone-600 dark:text-stone-400 pl-1">
              <li>Open the downloaded <code className="text-stone-800 dark:text-stone-300 font-mono">Mountly-1.0.0.dmg</code>.</li>
              <li>Drag Mountly into your Applications folder.</li>
              <li>Launch Mountly and connect your drive.</li>
            </ol>
          </div>
        </div>
      </div>
    </div>
  );
}
