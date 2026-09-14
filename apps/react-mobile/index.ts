import { registerRootComponent } from 'expo';

import App from './App';

// registerRootComponent calls AppRegistry.registerComponent('main', () => App)
// and sets up the environment appropriately whether the app is running in
// Expo Go, a native build, or the web.
registerRootComponent(App);
