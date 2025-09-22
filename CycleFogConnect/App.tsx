import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, ActivityIndicator } from 'react-native';
import { useAuthStore } from './src/stores/authStore';

export default function App() {
  const { user, loading, initialize } = useAuthStore();

  useEffect(() => {
    initialize();
  }, [initialize]);

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#2196F3" />
        <Text style={styles.loadingText}>Loading CycleFog Connect...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>CycleFog Connect</Text>
      <Text style={styles.subtitle}>
        {user ? `Welcome back, ${user.displayName}!` : 'Ready to explore new cycling routes?'}
      </Text>
      
      {!user && (
        <View style={styles.authContainer}>
          <Text style={styles.authText}>Please sign in to continue</Text>
        </View>
      )}
      
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAFAFA',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  loadingContainer: {
    flex: 1,
    backgroundColor: '#FAFAFA',
    alignItems: 'center',
    justifyContent: 'center',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#757575',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2196F3',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    color: '#212121',
    textAlign: 'center',
    marginBottom: 32,
  },
  authContainer: {
    padding: 20,
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  authText: {
    fontSize: 16,
    color: '#757575',
    textAlign: 'center',
  },
});