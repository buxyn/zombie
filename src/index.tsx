import { NativeModules, NativeEventEmitter } from 'react-native';

const { ZombieGps } = NativeModules;

const emitter = new NativeEventEmitter(ZombieGps);

export type ZombieLocation = {
  latitude: number;
  longitude: number;
  timestamp: number;
};

export function startMonitoring() {
  ZombieGps.startMonitoring();
}

export function stopMonitoring() {
  ZombieGps.stopMonitoring();
}

export function addListener(callback: (location: ZombieLocation) => void) {
  return emitter.addListener('ZombieGPSLocation', (...args: unknown[]) => {
    const [payload] = args;
    callback(payload as ZombieLocation);
  });
}
