// Utility for simulating errors in save/load operations
class ErrorSimulation {
  static bool shouldSimulateError = false;

  static void triggerError() {
    shouldSimulateError = true;
  }

  static void reset() {
    shouldSimulateError = false;
  }
}
