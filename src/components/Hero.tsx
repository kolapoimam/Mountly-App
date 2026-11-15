import { Download, Heart } from 'lucide-react';
import { DONATE_URL, DOWNLOAD_URL } from './Brand';
import { ProductPreview } from './ProductPreview';

const ENCLOSURES = [
  { label: 'USB-C', dot: 'bg-cobalt' },
  { label: 'USB-A', dot: 'bg-tangerine' },
  { label: 'Portable SSDs', dot: 'bg-mint' },
  { label: 'Mechanical HDDs', dot: 'bg-sun' },
  { label: 'Flash media', dot: 'bg-lilac' },
];

export function Hero() {
  return (
    <section id="top" className="relative px-5 pb-10 pt-16 sm:px-6 sm:pt-20">
      <div className="mx-auto flex max-w-6xl flex-col items-center text-center">
        <h1 className="max-w-[1000px] font-display text-[clamp(46px,7.4vw,104px)] font-extrabold leading-[0.98] tracking-[-0.045em] text-ink">
          External drives, made{' '}
          <span className="mt-[0.1em] inline-block -rotate-2 rounded-[0.18em] bg-sun px-[0.16em] pb-[0.06em]">
            accessible.
          </span>
        </h1>

        <p className="mt-8 max-w-[620px] text-[clamp(17px,1.6vw,20px)] leading-relaxed text-muted">
          Mountly gives your Mac a simpler way to work with external filesystems that macOS doesn't fully support out of the box.
        </p>

        <div className="mt-9 flex w-full flex-col items-center justify-center gap-3 sm:w-auto sm:flex-row">
          <a
            id="hero-download-button"
            href={DOWNLOAD_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex min-h-14 w-full items-center justify-center gap-2.5 rounded-full bg-ink px-7 text-[17px] font-semibold text-white shadow-[0_6px_0_var(--color-cobalt)] hover:-translate-y-0.5 hover:bg-black hover:shadow-[0_8px_0_var(--color-cobalt)] active:translate-y-0.5 active:shadow-[0_3px_0_var(--color-cobalt)] focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt focus-visible:ring-offset-4 focus-visible:ring-offset-cream sm:w-auto"
          >
            <Download className="h-[18px] w-[18px]" strokeWidth={2.2} aria-hidden="true" />
            Download Mountly
          </a>
          <a
            id="hero-donate-button"
            href={DONATE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex min-h-14 w-full items-center justify-center gap-2.5 rounded-full border-[1.5px] border-line-2 bg-white px-6 text-[17px] font-semibold text-ink hover:bg-cream-2 focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt focus-visible:ring-offset-4 focus-visible:ring-offset-cream sm:w-auto"
          >
            <Heart className="h-[18px] w-[18px] fill-[#e8567f] text-berry" strokeWidth={1.6} aria-hidden="true" />
            Donate
          </a>
        </div>
      </div>

      {/* Interactive product stage */}
      <div className="relative mx-auto mt-20 max-w-[1120px] sm:mt-24">
        <div aria-hidden="true" className="absolute inset-x-[4%] -bottom-9 top-16 rounded-[40px] bg-cobalt" />
        <div aria-hidden="true" className="dot-grid absolute inset-x-[4%] -bottom-9 top-16 rounded-[40px]" />


        <div className="relative z-[5] mx-0 sm:mx-[7%]">
          <ProductPreview />
        </div>
      </div>

      <div className="mx-auto mt-24 flex max-w-[1000px] flex-wrap items-center justify-center gap-x-3.5 gap-y-3">
        <span className="mr-1.5 text-sm text-subtle">Works with any enclosure</span>
        {ENCLOSURES.map((item) => (
          <span
            key={item.label}
            className="inline-flex items-center gap-2 rounded-full border border-line bg-white px-4 py-2 text-sm font-medium text-ink"
          >
            <span className={`h-2 w-2 rounded-full ${item.dot}`} aria-hidden="true" />
            {item.label}
          </span>
        ))}
      </div>
    </section>
  );
}
