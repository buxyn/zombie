import { NativeModules, NativeEventEmitter } from 'react-native';

export type ZombieLocation = {
  latitude: number;
  longitude: number;
  timestamp: number;
};

export type ZombieGpsReadyConfig = {
  apiURL: string;
  headers?: Record<string, string>;
  params?: Record<string, unknown>;
};

type ZombieGpsNativeModule = {
  startMonitoring: () => void;
  stopMonitoring: () => void;
  ready: (config: ZombieGpsReadyConfig) => Promise<void>;
};

const { ZombieGps } = NativeModules as {
  ZombieGps: ZombieGpsNativeModule;
};

const emitter = new NativeEventEmitter(NativeModules.ZombieGps);

export function startMonitoring() {
  ZombieGps.startMonitoring();
}

export function stopMonitoring() {
  ZombieGps.stopMonitoring();
}

export function ready(config: ZombieGpsReadyConfig) {
  return ZombieGps.ready(config);
}

export function addListener(callback: (location: ZombieLocation) => void) {
  return emitter.addListener('ZombieGPSLocation', (...args: unknown[]) => {
    const [payload] = args;
    callback(payload as ZombieLocation);
  });
}
