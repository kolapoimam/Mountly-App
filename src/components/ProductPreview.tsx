import { useEffect, useRef, useState } from 'react';
import { CheckCircle2, Circle, Folder, HardDrive, RefreshCw, Unplug, Plug } from 'lucide-react';
import type { DriveItem } from '../types';

type Tone = 'cobalt' | 'tangerine' | 'lilac';

interface PreviewDrive extends DriveItem {
  tone: Tone;
}

const INITIAL_DRIVES: PreviewDrive[] = [
  {
    id: 'ssd-1',
    name: 'External SSD',
    filesystem: 'NTFS',
    status: 'Mounted',
    accessType: 'Read & Write',
    totalSpaceGb: 1000,
    usedSpaceGb: 624,
    interfaceType: 'USB-C',
    isVerified: true,
    tone: 'cobalt',
  },
  {
    id: 'sandisk-1',
    name: 'SanDisk Extreme',
    filesystem: 'exFAT',
    status: 'Mounted',
    accessType: 'Native',
    totalSpaceGb: 500,
    usedSpaceGb: 215,
    interfaceType: 'USB 3.2',
    isVerified: true,
    tone: 'tangerine',
  },
  {
    id: 'archive-1',
    name: 'Archive HDD',
    filesystem: 'NTFS',
    status: 'Mounted',
    accessType: 'Read & Write',
    totalSpaceGb: 2000,
    usedSpaceGb: 1480,
    interfaceType: 'USB 3.2',
    isVerified: true,
    tone: 'lilac',
  },
];

// Full class strings so Tailwind can see them
const TONES: Record<Tone, { solid: string; ring: string; shadow: string; bar: string }> = {
  cobalt: {
    solid: 'bg-cobalt',
    ring: 'border-cobalt',
    shadow: 'shadow-[0_4px_12px_rgba(44,75,219,0.14)]',
    bar: 'bg-cobalt',
  },
  tangerine: {
    solid: 'bg-tangerine',
    ring: 'border-tangerine',
    shadow: 'shadow-[0_4px_12px_rgba(238,106,47,0.16)]',
    bar: 'bg-tangerine',
  },
  lilac: {
    solid: 'bg-lilac',
    ring: 'border-lilac',
    shadow: 'shadow-[0_4px_12px_rgba(109,85,232,0.16)]',
    bar: 'bg-lilac',
  },
};

const FS_CHIP: Record<string, string> = {
  NTFS: 'bg-cobalt-tint text-cobalt-ink',
  exFAT: 'bg-tangerine-tint text-tangerine-ink',
};

function formatSize(gb: number) {
  return gb >= 1000 ? `${gb / 1000} TB` : `${gb} GB`;
}

export function ProductPreview() {
  const [drives, setDrives] = useState<PreviewDrive[]>(INITIAL_DRIVES);
  const [selectedId, setSelectedId] = useState('ssd-1');
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const timers = useRef<number[]>([]);

  useEffect(() => () => timers.current.forEach((t) => window.clearTimeout(t)), []);

  const later = (fn: () => void, ms: number) => {
    timers.current.push(window.setTimeout(fn, ms));
  };

  const flash = (message: string, ms = 3000) => {
    setNotice(message);
    later(() => setNotice((current) => (current === message ? null : current)), ms);
  };

  const active = drives.find((d) => d.id === selectedId) ?? drives[0];
  const tone = TONES[active.tone];
  const mounted = active.status === 'Mounted';
  const free = active.totalSpaceGb - active.usedSpaceGb;
  const usedPct = Math.round((active.usedSpaceGb / active.totalSpaceGb) * 100);
  const isNative = active.accessType === 'Native';

  const toggleMount = () => {
    setDrives((prev) =>
      prev.map((d) =>
        d.id === active.id ? { ...d, status: d.status === 'Mounted' ? 'Unmounted' : 'Mounted' } : d
      )
    );
    flash(mounted ? `Safely ejected ${active.name}` : `Mounted ${active.name}`);
  };

  const openFinder = () => flash(`Opened /Volumes/${active.name} in Finder`);

  const refresh = () => {
    setIsRefreshing(true);
    setNotice('Scanning connected buses for storage devices…');
    later(() => {
      setIsRefreshing(false);
      flash('All connected volumes up to date', 2500);
    }, 900);
  };

  return (
    <div
      id="product-preview-window"
      className="overflow-hidden rounded-[18px] border border-[#e3daca] bg-white text-left text-ink shadow-[0_30px_60px_-20px_rgba(27,26,23,0.35)]"
    >
      {/* Title bar */}
      <div className="flex h-12 select-none items-center justify-between border-b border-[#ece4d4] bg-[#f6f2ea] px-4">
        <div className="flex items-center gap-2">
          <span className="h-3 w-3 rounded-full bg-[#ff5f57]" />
          <span className="h-3 w-3 rounded-full bg-[#febc2e]" />
          <span className="h-3 w-3 rounded-full bg-[#28c840]" />
          <span className="ml-3 text-[13px] font-semibold text-muted">Mountly</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-mint-tint px-2.5 py-1 text-xs font-semibold text-mint-ink">
            <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-mint" />
            Helper Active
          </span>
          <button
            type="button"
            onClick={refresh}
            aria-label="Rescan drives"
            title="Rescan drives"
            className="flex h-8 w-8 items-center justify-center rounded-lg text-subtle hover:bg-cream-2 hover:text-ink focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt"
          >
            <RefreshCw className={`h-4 w-4 ${isRefreshing ? 'animate-spin text-cobalt' : ''}`} />
          </button>
        </div>
      </div>

      {/* Toast */}
      <div aria-live="polite">
        {notice && (
          <div className="toast-in flex items-center justify-between gap-3 border-b border-sun/40 bg-sun-tint px-4 py-2.5 text-[13px] font-medium text-ink">
            <span className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 shrink-0 text-mint" />
              {notice}
            </span>
            <span className="hidden font-mono text-[11px] uppercase tracking-wider text-sun-ink sm:inline">
              macOS notice
            </span>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-[minmax(270px,0.42fr)_1fr]">
        {/* Sidebar */}
        <aside className="flex flex-col gap-1.5 border-b border-[#ece4d4] bg-paper px-3.5 py-5 md:border-b-0 md:border-r">
          <div className="flex items-baseline justify-between px-2 pb-2.5">
            <span className="text-xs font-semibold uppercase tracking-[0.06em] text-subtle">Your Drives</span>
            <span className="font-mono text-[11px] text-subtle">{drives.length} detected</span>
          </div>

          {drives.map((drive) => {
            const t = TONES[drive.tone];
            const selected = drive.id === selectedId;
            const isMounted = drive.status === 'Mounted';
            return (
              <button
                key={drive.id}
                type="button"
                onClick={() => setSelectedId(drive.id)}
                aria-pressed={selected}
                className={`flex w-full items-center gap-3 rounded-xl border-[1.5px] p-2.5 text-left focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt ${
                  selected ? `bg-white ${t.ring} ${t.shadow}` : 'border-transparent hover:bg-white/70'
                }`}
              >
                <span
                  className={`flex h-[34px] w-[34px] shrink-0 items-center justify-center rounded-[10px] text-white transition-opacity ${t.solid} ${
                    isMounted ? '' : 'opacity-40'
                  }`}
                >
                  <HardDrive className="h-[17px] w-[17px]" strokeWidth={2.2} />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block truncate text-sm font-semibold">{drive.name}</span>
                  <span className="block text-xs text-subtle">
                    {formatSize(drive.totalSpaceGb)} · {drive.status}
                  </span>
                </span>
                <span className={`rounded-md px-1.5 py-0.5 font-mono text-[11px] ${FS_CHIP[drive.filesystem]}`}>
                  {drive.filesystem}
                </span>
              </button>
            );
          })}

          <div className="mt-auto flex flex-col gap-2.5 border-t border-dashed border-line-2 px-2 pt-5 text-xs">
            <div className="flex justify-between">
              <span className="text-subtle">Kernel extension</span>
              <span className="font-mono">Not required</span>
            </div>
            <div className="flex justify-between">
              <span className="text-subtle">FUSE compatibility</span>
              <span className="font-mono text-mint-ink">Verified</span>
            </div>
          </div>
        </aside>

        {/* Detail */}
        <div className="flex min-w-0 flex-col gap-6 p-5 sm:p-7">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div className="flex items-center gap-3.5">
              <span
                className={`flex h-12 w-12 shrink-0 items-center justify-center rounded-[14px] text-white shadow-[inset_0_-3px_0_rgba(0,0,0,0.18)] transition-colors ${tone.solid}`}
              >
                <HardDrive className="h-[22px] w-[22px]" strokeWidth={2.1} />
              </span>
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <h3 className="font-display text-xl font-bold tracking-[-0.01em]">{active.name}</h3>
                  <span className={`rounded-md px-1.5 py-0.5 font-mono text-[11px] ${FS_CHIP[active.filesystem]}`}>
                    {active.filesystem}
                  </span>
                </div>
                <p className="mt-0.5 text-[13px] text-subtle">
                  {active.interfaceType} storage · {mounted ? `Mounted at /Volumes/${active.name}` : 'Not mounted'}
                </p>
              </div>
            </div>
            <span
              className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1.5 text-[13px] font-semibold ${
                mounted ? 'bg-mint-tint text-mint-ink' : 'bg-cream-2 text-subtle'
              }`}
            >
              <span className={`h-[7px] w-[7px] rounded-full ${mounted ? 'bg-mint' : 'bg-[#a8a092]'}`} />
              {mounted ? active.accessType : 'Ejected'}
            </span>
          </div>

          <div>
            <div className="flex flex-wrap items-end justify-between gap-2">
              <div className="flex items-baseline gap-2">
                <span className="font-display text-[40px] font-bold leading-none tracking-[-0.03em]">
                  {formatSize(active.totalSpaceGb)}
                </span>
                <span className="text-sm text-subtle">Total capacity</span>
              </div>
              <div className="text-right">
                <div className="text-sm font-semibold">{free} GB available</div>
                <div className="text-xs text-subtle">
                  {active.usedSpaceGb} GB used ({usedPct}%)
                </div>
              </div>
            </div>
            <div
              className="mt-3.5 h-3.5 overflow-hidden rounded-full bg-cream-2"
              role="meter"
              aria-label="Storage used"
              aria-valuenow={usedPct}
              aria-valuemin={0}
              aria-valuemax={100}
            >
              <div
                className={`h-full rounded-full transition-all duration-500 ${tone.bar} ${mounted ? '' : 'opacity-35'}`}
                style={{ width: `${usedPct}%` }}
              />
            </div>
            <div className="mt-3 flex flex-wrap justify-between gap-2 text-xs text-muted">
              <div className="flex gap-4">
                <span className="inline-flex items-center gap-1.5">
                  <span className={`h-[9px] w-[9px] rounded-[3px] ${tone.bar}`} />
                  Files &amp; Data
                </span>
                <span className="inline-flex items-center gap-1.5">
                  <span className="h-[9px] w-[9px] rounded-[3px] border border-[#d9cfbc] bg-cream-2" />
                  Free Space
                </span>
              </div>
              <span className="font-mono text-subtle">Cluster size: 4096 bytes</span>
            </div>
          </div>

          <div className="rounded-[14px] border border-[#ece4d4] bg-paper px-4 py-1.5 text-sm">
            <div className="flex items-center justify-between gap-3 border-b border-[#ece4d4] py-2.5">
              <span className="flex items-center gap-2.5">
                {mounted ? (
                  <CheckCircle2 className="h-[17px] w-[17px] shrink-0 text-mint" />
                ) : (
                  <Circle className="h-[17px] w-[17px] shrink-0 text-[#b5ad9e]" />
                )}
                {mounted ? 'Mounted with clean journal state' : 'Volume safely ejected'}
              </span>
              <span className="text-xs text-subtle">{mounted ? 'Ready' : 'Idle'}</span>
            </div>
            <div className="flex items-center justify-between gap-3 py-2.5">
              <span className="flex items-center gap-2.5">
                {mounted ? (
                  <CheckCircle2 className="h-[17px] w-[17px] shrink-0 text-mint" />
                ) : (
                  <Circle className="h-[17px] w-[17px] shrink-0 text-[#b5ad9e]" />
                )}
                {isNative ? 'Handled natively by macOS' : 'Write access verified via Mountly backend'}
              </span>
              <span className={`font-mono text-xs font-medium ${mounted ? 'text-mint-ink' : 'text-subtle'}`}>
                {mounted ? 'Active' : 'Off'}
              </span>
            </div>
          </div>

          <div className="flex flex-wrap justify-between gap-2.5">
            <button
              type="button"
              id="preview-open-finder"
              onClick={openFinder}
              disabled={!mounted}
              className="inline-flex min-h-10 items-center gap-2 rounded-[10px] border border-line-2 bg-white px-4 text-sm font-medium text-ink hover:bg-cream-2 focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt disabled:cursor-not-allowed disabled:opacity-50"
            >
              <Folder className="h-[15px] w-[15px] text-cobalt" strokeWidth={2.1} />
              Open in Finder
            </button>
            <button
              type="button"
              id="preview-toggle-eject"
              onClick={toggleMount}
              className={`inline-flex min-h-10 items-center gap-2 rounded-[10px] px-4 text-sm font-semibold focus:outline-none focus-visible:ring-2 focus-visible:ring-cobalt ${
                mounted
                  ? 'bg-tangerine-tint text-tangerine-ink hover:bg-[#fbd6c0]'
                  : 'bg-mint-tint text-mint-ink hover:bg-[#c3e8d5]'
              }`}
            >
              {mounted ? <Unplug className="h-[15px] w-[15px]" /> : <Plug className="h-[15px] w-[15px]" />}
              {mounted ? 'Eject Volume' : 'Mount Volume'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
