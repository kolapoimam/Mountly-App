import { ArrowUpDown, Download, Folder, HardDrive, Heart, ShieldCheck } from 'lucide-react';
import { DONATE_URL, DOWNLOAD_URL } from './Brand';

export function DownloadSection() {
  return (
    <section id="download" className="px-5 pb-24 pt-16 sm:px-6 md:pb-28">
      <div className="relative mx-auto max-w-6xl overflow-hidden rounded-[40px] bg-cobalt px-6 py-[clamp(56px,7vw,96px)] text-center text-white">
        <div aria-hidden="true" className="dot-grid absolute inset-0" />

        <span aria-hidden="true" className="absolute left-[6%] top-[18%] hidden h-[84px] w-[84px] -rotate-12 items-center justify-center rounded-3xl bg-tangerine shadow-[inset_0_-6px_0_rgba(0,0,0,0.15)] md:flex">
          <HardDrive className="h-[38px] w-[38px]" strokeWidth={2} />
        </span>
        <span aria-hidden="true" className="absolute right-[7%] top-[14%] hidden h-[70px] w-[70px] rotate-[10deg] items-center justify-center rounded-[20px] bg-sun text-ink shadow-[inset_0_-6px_0_rgba(0,0,0,0.12)] md:flex">
          <Folder className="h-8 w-8" strokeWidth={2} />
        </span>
        <span aria-hidden="true" className="absolute bottom-[14%] right-[12%] hidden h-[76px] w-[76px] -rotate-6 items-center justify-center rounded-[22px] bg-mint shadow-[inset_0_-6px_0_rgba(0,0,0,0.15)] md:flex">
          <ShieldCheck className="h-[34px] w-[34px]" strokeWidth={2} />
        </span>
        <span aria-hidden="true" className="absolute bottom-[12%] left-[11%] hidden h-[60px] w-[60px] rotate-[14deg] items-center justify-center rounded-[18px] bg-berry shadow-[inset_0_-6px_0_rgba(0,0,0,0.15)] md:flex">
          <ArrowUpDown className="h-[26px] w-[26px]" strokeWidth={2.2} />
        </span>

        <div className="relative mx-auto max-w-[640px]">
          <h2 className="font-display text-[clamp(36px,5vw,64px)] font-extrabold leading-[1.02] tracking-[-0.035em]">
            Ready to mount your external drives?
          </h2>
          <p className="mx-auto mt-5 max-w-[460px] text-lg leading-relaxed text-[#e3e8ff]">
            Get Mountly for macOS. Free, open source, and built for your hardware.
          </p>
          <div className="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <a
              id="download-section-primary-btn"
              href={DOWNLOAD_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex min-h-14 w-full items-center justify-center gap-2.5 rounded-full bg-cream px-7 text-[17px] font-semibold text-ink shadow-[0_6px_0_var(--color-ink)] hover:-translate-y-0.5 hover:bg-white active:translate-y-0.5 active:shadow-[0_3px_0_var(--color-ink)] focus:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-4 focus-visible:ring-offset-cobalt sm:w-auto"
            >
              <Download className="h-[18px] w-[18px]" strokeWidth={2.2} aria-hidden="true" />
              Download Mountly
            </a>
            <a
              id="support-mountly-donate-btn"
              href={DONATE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex min-h-14 w-full items-center justify-center gap-2.5 rounded-full border-[1.5px] border-white/55 px-6 text-[17px] font-semibold text-white hover:bg-white/10 focus:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-4 focus-visible:ring-offset-cobalt sm:w-auto"
            >
              <Heart className="h-[18px] w-[18px] fill-white" strokeWidth={1.6} aria-hidden="true" />
              Donate
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
