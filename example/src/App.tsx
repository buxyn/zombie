import { useEffect, useState } from 'react';
import { SafeAreaView, StyleSheet, Text } from 'react-native';
import {
  ready,
  startMonitoring,
  addListener,
  type ZombieLocation,
} from 'react-native-zombie-gps';

const SUPABASE_URL = 'SUPABASE_URL';
const SUPABASE_ANON_KEY = 'SUPABASE_ANON_KEY';
const SUPABASE_TABLE = 'SUPABASE_TABLE';

export default function App() {
  const [location, setLocation] = useState<ZombieLocation | null>(null);

  useEffect(() => {
    console.log('App started');
    addListener((loc: ZombieLocation) => {
      console.log('SLC:', loc);
      setLocation(loc);
    });

    let mounted = true;
    (async () => {
      if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
        console.warn('Configure Supabase credentials to enable uploads.');
        return;
      }

      try {
        await ready({
          apiURL: `${SUPABASE_URL}/rest/v1/${SUPABASE_TABLE}`,
          headers: {
            'apikey': SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
            'Content-Type': 'application/json',
          },
        });

        if (mounted) {
          startMonitoring();
        }
      } catch (error) {
        console.error('Failed to configure Zombie GPS upload target', error);
      }
    })();
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
