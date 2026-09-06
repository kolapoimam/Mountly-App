import { useState } from 'react';
import { ChevronDown, Download, Heart } from 'lucide-react';

interface FaqItem {
  q: string;
  a: string;
}

interface FAQProps {
  onOpenDownload?: () => void;
  onOpenDonate?: () => void;
}

export function FAQ({ onOpenDownload, onOpenDonate }: FAQProps) {
  const [openIndices, setOpenIndices] = useState<number[]>([0, 1]);

  const toggle = (index: number) => {
    setOpenIndices((prev) =>
      prev.includes(index) ? prev.filter((i) => i !== index) : [...prev, index]
    );
  };

  const faqs: FaqItem[] = [
    {
      q: 'What is Mountly?',
      a: 'Mountly is a native macOS utility designed to detect, mount, and manage supported external drives and filesystems with seamless Finder integration.',
    },
    {
      q: 'Does Mountly support NTFS write access?',
      a: 'Yes. Mountly enables supported read and write operations on NTFS drives without requiring terminal commands or kernel extension hacks.',
    },
    {
      q: 'Do I need to format or erase my drive?',
      a: 'No. Mountly is built so you never have to erase or reformat an existing drive simply because you plugged it into a Mac.',
    },
    {
      q: 'What types of drives are supported?',
      a: 'Mountly works with any external enclosure — USB-C, USB-A, external SSDs, mechanical hard drives, and flash cards regardless of brand.',
    },
    {
      q: 'Does Mountly modify or collect my files?',
      a: 'No. Mountly runs entirely offline on your Mac, collects zero telemetry, and performs operations strictly requested by you.',
    },
  ];

  return (
    <section id="faq" className="py-20 md:py-28 border-t border-stone-800/80 bg-stone-950">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-xl mx-auto mb-14 space-y-3">
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight text-white">
            Frequently Asked Questions
          </h2>
          <p className="text-base text-stone-400">
            Answers to common questions about drive compatibility, safety, and filesystems.
          </p>
        </div>

        <div className="divide-y divide-stone-800/80 border-y border-stone-800/80">
          {faqs.map((faq, idx) => {
            const isOpen = openIndices.includes(idx);
            return (
              <div key={faq.q} className="py-5">
                <button
                  type="button"
                  onClick={() => toggle(idx)}
                  className="flex w-full items-center justify-between text-left focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 rounded-md py-1"
                  aria-expanded={isOpen}
                >
                  <span className="text-base font-semibold text-stone-100 pr-4">
                    {faq.q}
                  </span>
                  <ChevronDown
                    className={`h-4 w-4 text-stone-400 transition-transform duration-200 shrink-0 ${
                      isOpen ? 'rotate-180 text-blue-400' : ''
                    }`}
                  />
                </button>

                {isOpen && (
                  <div className="mt-3 text-sm text-stone-300 leading-relaxed pr-6 animate-in fade-in duration-150">
                    {faq.a}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Minimal Bottom CTA Card */}
        <div className="mt-14 rounded-2xl border border-stone-800 bg-stone-900/40 p-8 text-center space-y-4">
          <h3 className="text-xl font-bold text-white">
            Ready to mount your external drives?
          </h3>
          <p className="text-sm text-stone-400 max-w-md mx-auto">
            Get Mountly for macOS. Free, open source, and built for your hardware.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
            <a
              id="faq-download-button"
              href="https://drive.google.com/drive/folders/10siVhoTd4-5X_bA3s5Ns0AYtGD87D95s?usp=sharing"
              target="_blank"
              rel="noopener noreferrer"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-full bg-blue-600 hover:bg-blue-500 text-white font-semibold text-xs shadow-md shadow-blue-900/20 hover:shadow-blue-800/30 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 active:scale-[0.98]"
            >
              <Download className="h-3.5 w-3.5" />
              <span>Download Mountly</span>
            </a>
            <a
              id="faq-donate-button"
              href="https://paystack.shop/pay/pmbuddy"
              target="_blank"
              rel="noopener noreferrer"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-4 py-2.5 rounded-full border border-stone-700 hover:border-stone-600 bg-stone-800 hover:bg-stone-700 text-stone-300 hover:text-white font-medium text-xs transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
            >
              <Heart className="h-3.5 w-3.5 text-blue-400" />
              <span>Donate</span>
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
