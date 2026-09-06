export type FilesystemStatus = 'Supported' | 'Native' | 'Limited' | 'Coming later';

export interface FilesystemInfo {
  name: string;
  badge: FilesystemStatus;
  detail: string;
  description: string;
  writeSupported: boolean;
}

export interface DriveItem {
  id: string;
  name: string;
  filesystem: string;
  status: 'Mounted' | 'Unmounted' | 'Needs attention';
  accessType: 'Read & Write' | 'Read Only' | 'Native';
  totalSpaceGb: number;
  usedSpaceGb: number;
  interfaceType: 'USB-C' | 'USB 3.2' | 'Thunderbolt';
  isVerified: boolean;
}

export type ThemeMode = 'dark' | 'light';
