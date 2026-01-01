import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export type ZombieGpsReadyConfig = {
  apiURL: string;
  headers?: Object;
  params?: Object;
  locationFormat?: string;
  geohashLength?: number;
};

export interface Spec extends TurboModule {
  startMonitoring(): void;
  stopMonitoring(): void;
  ready(config: ZombieGpsReadyConfig): Promise<void>;

  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('ZombieGps');
