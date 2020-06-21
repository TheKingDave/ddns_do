extension ExtendedMap<K, V> on Map<K, V> {
  bool containsAllKeys(List<K> keys) {
    for (var key in keys) {
      if (!containsKey(key)) return false;
    }
    return true;
  }
}
