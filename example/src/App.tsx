import { useEffect, useState } from 'react';
import { SafeAreaView, StyleSheet, Text } from 'react-native';
import {
  startMonitoring,
  addListener,
  type ZombieLocation,
} from 'react-native-zombie-gps';

export default function App() {
  const [location, setLocation] = useState<ZombieLocation | null>(null);

  useEffect(() => {
    console.log('App started');
    addListener((loc: ZombieLocation) => {
      console.log('SLC:', loc);
      setLocation(loc);
    });

    startMonitoring();
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Zombie GPS Example</Text>
      <Text style={styles.subtitle}>
        {location ? 'Current Significant Location' : 'Waiting for location...'}
      </Text>
      <Text style={styles.coords}>
        Lat: {location ? location.latitude.toFixed(6) : '--'}
      </Text>
      <Text style={styles.coords}>
        Lng: {location ? location.longitude.toFixed(6) : '--'}
      </Text>
      {location ? (
        <Text style={styles.timestamp}>
          Updated:{' '}
          {new Date(location.timestamp * 1000).toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
          })}
        </Text>
      ) : null}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#0f172a',
    padding: 24,
  },
  title: {
    fontSize: 32,
    fontWeight: '700',
    color: '#f8fafc',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    color: '#cbd5f5',
    marginBottom: 16,
  },
  coords: {
    fontSize: 24,
    fontVariant: ['tabular-nums'],
    color: '#e2e8f0',
  },
  timestamp: {
    marginTop: 18,
    fontSize: 16,
    color: '#94a3b8',
  },
});
