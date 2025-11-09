# Zombie

<img src="./assets/ZombieIcon.png" width=400px height=400px>

A React Native module for persistent background location tracking that keeps working even after the app is killed.

## Installation

```sh
npm install react-native-zombie-gps
# or
yarn add react-native-zombie-gps
```

## Usage

```ts
import {
  addListener,
  ready,
  startMonitoring,
  stopMonitoring,
} from 'react-native-zombie-gps';

async function bootstrapZombieGps() {
  await ready({
    apiURL: 'https://example.supabase.co/rest/v1/locations',
    headers: {
      'apikey': 'public-anon-key',
      'Authorization': 'Bearer public-anon-key',
      'Content-Type': 'application/json',
    },
    params: {
      sessionId: 'demo-session',
    },
  });

  const subscription = addListener((location) => {
    console.log(
      `lat=${location.latitude}, lng=${location.longitude} @ ${location.timestamp}`
    );
  });

  startMonitoring();

  return () => {
    subscription.remove?.();
    stopMonitoring();
  };
}
```

`ready` persists the upload config natively so that when iOS restarts the app in the background the native module can continue POSTing payloads shaped as `{ lat, lng, timestamp, params }` even before the React Native bridge is alive. See `example/src/App.tsx` for a UI example that renders the active coordinates and configures a Supabase endpoint.

## Development

```sh
yarn lint          # eslint
yarn format        # prettier --check
yarn format:write  # prettier --write
yarn pre-push      # lint + format (ideal for git hooks)
```

## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT
