import { useState } from 'react';
import {
  HardDrive,
  Folder,
  Unplug,
  CheckCircle2,
  RefreshCw,
} from 'lucide-react';
import type { DriveItem } from '../types';

const INITIAL_DRIVES: DriveItem[] = [
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
  },
];

export function ProductPreview() {
  const [drives, setDrives] = useState<DriveItem[]>(INITIAL_DRIVES);
  const [selectedId, setSelectedId] = useState<string>('ssd-1');
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [bannerNotice, setBannerNotice] = useState<string | null>(null);

  const activeDrive = drives.find((d) => d.id === selectedId) || drives[0];

  const handleOpenFinder = () => {
    setBannerNotice(`Opened /Volumes/${activeDrive.name} in Finder`);
    setTimeout(() => {
      setBannerNotice(null);
    }, 3200);
  };

  const handleToggleMount = () => {
    setDrives((prev) =>
      prev.map((d) => {
        if (d.id === activeDrive.id) {
          const nextStatus = d.status === 'Mounted' ? 'Unmounted' : 'Mounted';
          return {
            ...d,
            status: nextStatus,
          };
        }
        return d;
      })
    );
    const actionWord = activeDrive.status === 'Mounted' ? 'Safely ejected' : 'Mounted';
    setBannerNotice(`${actionWord} ${activeDrive.name}`);
    setTimeout(() => {
      setBannerNotice(null);
    }, 3200);
  };

  const handleRefresh = () => {
    setIsRefreshing(true);
    setBannerNotice('Scanning connected buses for storage devices...');
    setTimeout(() => {
      setIsRefreshing(false);
      setBannerNotice('All connected volumes up to date');
      setTimeout(() => setBannerNotice(null), 2500);
    }, 800);
  };

  const freeSpaceGb = activeDrive.totalSpaceGb - activeDrive.usedSpaceGb;
  const usedPercentage = Math.round((activeDrive.usedSpaceGb / activeDrive.totalSpaceGb) * 100);

  return (
    <div className="relative w-full max-w-4xl mx-auto group">
      {/* Ambient shadow / backing glow */}
      <div className="absolute -inset-1.5 rounded-3xl bg-gradient-to-b from-blue-500/10 via-stone-400/10 dark:via-stone-800/10 to-transparent blur-xl pointer-events-none transition-opacity duration-300 opacity-80" />

      {/* Main Window Container */}
      <div
        id="product-preview-window"
        className="relative rounded-2xl border border-stone-200 dark:border-stone-800/90 bg-white dark:bg-stone-900/95 shadow-2xl shadow-stone-900/10 dark:shadow-black/80 overflow-hidden text-stone-800 dark:text-stone-200 transition-all"
      >
        {/* macOS Window Titlebar */}
        <div className="flex h-11 items-center justify-between border-b border-stone-200 dark:border-stone-800/80 bg-stone-100/80 dark:bg-stone-900/90 px-4 select-none">
          <div className="flex items-center gap-2">
            <span className="h-3 w-3 rounded-full bg-[#FF5F56] border border-[#E0443E]/40" />
            <span className="h-3 w-3 rounded-full bg-[#FFBD2E] border border-[#DEA123]/40" />
            <span className="h-3 w-3 rounded-full bg-[#27C93F] border border-[#1AAB29]/40" />
            <span className="ml-3 text-xs font-semibold tracking-tight text-stone-600 dark:text-stone-400">
              Mountly
            </span>
          </div>

          <div className="flex items-center gap-2">
            <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded text-[11px] font-medium bg-stone-200/70 text-stone-700 dark:bg-stone-800/70 dark:text-stone-300 border border-stone-300/60 dark:border-stone-700/50">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
              Helper Active
            </span>
            <button
              type="button"
              onClick={handleRefresh}
              title="Rescan drives"
              aria-label="Rescan drives"
              className="p-1 rounded text-stone-500 hover:text-stone-800 dark:text-stone-400 dark:hover:text-stone-200 hover:bg-stone-200/70 dark:hover:bg-stone-800 transition-colors"
            >
              <RefreshCw className={`h-3.5 w-3.5 ${isRefreshing ? 'animate-spin text-blue-500 dark:text-blue-400' : ''}`} />
            </button>
          </div>
        </div>

        {/* Notice Banner when user clicks interaction */}
        {bannerNotice && (
          <div
            id="macos-banner-toast"
            className="flex items-center justify-between px-4 py-2 text-xs font-medium bg-blue-50 dark:bg-blue-950/80 border-b border-blue-200 dark:border-blue-800/60 text-blue-900 dark:text-blue-200 animate-in fade-in slide-in-from-top-1 duration-150"
          >
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 dark:text-blue-400 shrink-0" />
              <span>{bannerNotice}</span>
            </div>
            <span className="text-[10px] text-blue-600 dark:text-blue-400/80 uppercase tracking-wider font-mono">macOS Notice</span>
          </div>
        )}

        {/* Window Content: Master / Detail layout */}
        <div className="grid grid-cols-1 md:grid-cols-12 min-h-[380px]">
          {/* Left Sidebar: Drive list */}
          <aside className="md:col-span-4 border-b md:border-b-0 md:border-r border-stone-200 dark:border-stone-800/80 bg-stone-50 dark:bg-stone-950/50 p-3 space-y-3">
            <div className="px-2 pt-1 flex items-center justify-between text-[11px] font-semibold tracking-wider text-stone-500 dark:text-stone-400 uppercase">
              <span>Your Drives</span>
              <span className="text-stone-400 dark:text-stone-500 font-mono text-[10px]">{drives.length} detected</span>
            </div>

            <div className="space-y-1.5">
              {drives.map((drive) => {
                const isSelected = drive.id === selectedId;
                return (
                  <button
                    key={drive.id}
                    type="button"
                    onClick={() => setSelectedId(drive.id)}
                    className={`w-full text-left px-3 py-2.5 rounded-xl transition-all flex items-start gap-2.5 ${
                      isSelected
                        ? 'bg-blue-50 dark:bg-blue-600/15 border border-blue-200 dark:border-blue-500/40 text-blue-950 dark:text-white shadow-xs'
                        : 'hover:bg-stone-200/50 dark:hover:bg-stone-800/50 border border-transparent text-stone-700 dark:text-stone-300'
                    }`}
                  >
                    <div
                      className={`mt-0.5 p-1.5 rounded-lg ${
                        isSelected
                          ? 'bg-blue-100 text-blue-600 dark:bg-blue-500/20 dark:text-blue-400'
                          : 'bg-stone-200/80 text-stone-600 dark:bg-stone-800 dark:text-stone-400'
                      }`}
                    >
                      <HardDrive className="h-4 w-4" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between">
                        <p className="text-xs font-semibold truncate text-stone-900 dark:text-stone-100">
                          {drive.name}
                        </p>
                        <span
                          className={`text-[10px] font-mono px-1.5 py-0.2 rounded font-medium ${
                            drive.status === 'Mounted'
                              ? 'text-emerald-700 bg-emerald-100 border border-emerald-200 dark:text-emerald-400 dark:bg-emerald-950/40 dark:border-emerald-800/40'
                              : 'text-stone-600 bg-stone-200 dark:text-stone-400 dark:bg-stone-800'
                          }`}
                        >
                          {drive.filesystem}
                        </span>
                      </div>
                      <div className="flex items-center justify-between mt-1 text-[11px] text-stone-500 dark:text-stone-400">
                        <span>{drive.totalSpaceGb >= 1000 ? `${drive.totalSpaceGb / 1000} TB` : `${drive.totalSpaceGb} GB`}</span>
                        <span className="text-[10px] text-stone-400 dark:text-stone-500">{drive.status}</span>
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>

            <div className="pt-3 border-t border-stone-200 dark:border-stone-800/60 px-2 space-y-1">
              <div className="flex items-center justify-between text-[11px] text-stone-500 dark:text-stone-400">
                <span>Kernel extension</span>
                <span className="text-stone-800 dark:text-stone-300 font-mono">Not required</span>
              </div>
              <div className="flex items-center justify-between text-[11px] text-stone-500 dark:text-stone-400">
                <span>FUSE compatibility</span>
                <span className="text-blue-600 dark:text-blue-400 font-mono">Verified</span>
              </div>
            </div>
          </aside>

          {/* Right Detail Pane */}
          <main className="md:col-span-8 p-5 md:p-6 flex flex-col justify-between bg-white dark:bg-stone-900/40">
            <div>
              {/* Drive Header */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-5 border-b border-stone-100 dark:border-stone-800/80">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-xl bg-stone-100 dark:bg-stone-800 border border-stone-200 dark:border-stone-700/70 flex items-center justify-center text-stone-600 dark:text-stone-300 shadow-xs">
                    <HardDrive className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="text-base font-bold text-stone-900 dark:text-white tracking-tight">
                        {activeDrive.name}
                      </h4>
                      <span className="text-[10px] font-mono uppercase px-1.5 py-0.5 rounded bg-blue-100 text-blue-700 border border-blue-200 dark:bg-blue-950/80 dark:text-blue-300 dark:border-blue-800/60 font-medium">
                        {activeDrive.filesystem}
                      </span>
                    </div>
                    <p className="text-xs text-stone-500 dark:text-stone-400 mt-0.5">
                      {activeDrive.interfaceType} storage · {activeDrive.status === 'Mounted' ? `Mounted at /Volumes/${activeDrive.name}` : 'Unmounted'}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <span
                    className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium border ${
                      activeDrive.status === 'Mounted'
                        ? 'bg-emerald-50 border-emerald-200 text-emerald-800 dark:bg-emerald-950/40 dark:border-emerald-800/50 dark:text-emerald-300'
                        : 'bg-stone-100 border-stone-200 text-stone-600 dark:bg-stone-800 dark:border-stone-700 dark:text-stone-400'
                    }`}
                  >
                    <span
                      className={`h-1.5 w-1.5 rounded-full ${
                        activeDrive.status === 'Mounted' ? 'bg-emerald-500' : 'bg-stone-400'
                      }`}
                    />
                    {activeDrive.accessType}
                  </span>
                </div>
              </div>

              {/* Storage Capacity Bar */}
              <div className="py-5 space-y-3">
                <div className="flex items-baseline justify-between">
                  <div className="flex items-baseline gap-2">
                    <span className="text-2xl font-bold text-stone-900 dark:text-white tracking-tight">
                      {activeDrive.totalSpaceGb >= 1000
                        ? `${activeDrive.totalSpaceGb / 1000} TB`
                        : `${activeDrive.totalSpaceGb} GB`}
                    </span>
                    <span className="text-xs text-stone-500 dark:text-stone-400">Total capacity</span>
                  </div>
                  <div className="text-right">
                    <span className="text-xs font-semibold text-stone-800 dark:text-stone-200">
                      {freeSpaceGb} GB available
                    </span>
                    <span className="text-xs text-stone-400 dark:text-stone-500 block">
                      {activeDrive.usedSpaceGb} GB used ({usedPercentage}%)
                    </span>
                  </div>
                </div>

                {/* Visual Storage Meter */}
                <div className="w-full h-3 rounded-full bg-stone-200 dark:bg-stone-800 overflow-hidden p-0.5 border border-stone-300/80 dark:border-stone-700/60 flex">
                  <div
                    className="h-full rounded-l-full bg-blue-500 transition-all duration-500"
                    style={{ width: `${usedPercentage}%` }}
                    title={`Used: ${activeDrive.usedSpaceGb} GB`}
                  />
                  <div
                    className="h-full rounded-r-full bg-stone-300 dark:bg-stone-700/50 transition-all duration-500"
                    style={{ width: `${100 - usedPercentage}%` }}
                    title={`Free: ${freeSpaceGb} GB`}
                  />
                </div>

                <div className="flex items-center justify-between text-[11px] text-stone-500 dark:text-stone-400 pt-1">
                  <div className="flex items-center gap-4">
                    <span className="flex items-center gap-1.5">
                      <span className="h-2 w-2 rounded-full bg-blue-500" />
                      Files & Data
                    </span>
                    <span className="flex items-center gap-1.5">
                      <span className="h-2 w-2 rounded-full bg-stone-400 dark:bg-stone-600" />
                      Free Space
                    </span>
                  </div>
                  <span className="font-mono text-[10px] text-stone-400 dark:text-stone-500">
                    Cluster size: 4096 bytes
                  </span>
                </div>
              </div>

              {/* Status checklist */}
              <div className="rounded-xl bg-stone-50 dark:bg-stone-950/60 border border-stone-200 dark:border-stone-800/80 p-3.5 space-y-2 text-xs">
                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-2 text-stone-700 dark:text-stone-300">
                    <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400 shrink-0" />
                    <span>Mounted with clean journal state</span>
                  </span>
                  <span className="font-mono text-[11px] text-stone-500 dark:text-stone-400">Ready</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="flex items-center gap-2 text-stone-700 dark:text-stone-300">
                    <CheckCircle2 className="h-3.5 w-3.5 text-emerald-400 shrink-0" />
                    <span>Write access verified via Mountly backend</span>
                  </span>
                  <span className="font-mono text-[11px] text-emerald-600 dark:text-emerald-400 font-semibold">Active</span>
                </div>
              </div>
            </div>

            {/* Actions Bar */}
            <div className="pt-5 mt-4 border-t border-stone-100 dark:border-stone-800/80 flex flex-wrap items-center justify-between gap-3">
              <button
                type="button"
                id="preview-open-finder"
                onClick={handleOpenFinder}
                disabled={activeDrive.status !== 'Mounted'}
                className="inline-flex items-center gap-2 px-3.5 py-2 rounded-lg bg-stone-900 hover:bg-stone-800 text-white dark:bg-stone-800 dark:hover:bg-stone-700 dark:text-stone-100 font-medium text-xs border border-stone-800 dark:border-stone-700 transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed shadow-xs"
              >
                <Folder className="h-3.5 w-3.5 text-blue-400" />
                <span>Open in Finder</span>
              </button>

              <button
                type="button"
                id="preview-toggle-eject"
                onClick={handleToggleMount}
                className="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-xs font-medium text-stone-600 dark:text-stone-300 hover:text-stone-900 dark:hover:text-white hover:bg-stone-100 dark:hover:bg-stone-800/80 transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500"
              >
                <Unplug className="h-3.5 w-3.5 text-stone-500 dark:text-stone-400" />
                <span>{activeDrive.status === 'Mounted' ? 'Eject Volume' : 'Mount Volume'}</span>
              </button>
            </div>
          </main>
        </div>
      </div>
    </div>
  );
}
