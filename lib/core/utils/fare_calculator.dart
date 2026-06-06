import 'dart:collection';

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

enum RailLine { western, central, harbour }

class GraphStation {
  const GraphStation({
    required this.code,
    required this.name,
    required this.line,
  });

  final String code;
  final String name;
  final RailLine line;
}

class FareResult {
  const FareResult({
    required this.source,
    required this.destination,
    required this.route,
    required this.totalDistanceKm,
    required this.secondClassFare,
    required this.interchanges,
  });

  final String source;
  final String destination;
  final List<String> route;
  final double totalDistanceKm;
  final int secondClassFare;
  final List<String> interchanges;
}

// ---------------------------------------------------------------------------
// Fare Slabs — sorted ascending. O(1) lookup via binary-search style approach.
// ---------------------------------------------------------------------------

const List<({int minKm, int maxKm, int fare})> _fareSlabs = [
  (minKm: 0, maxKm: 20, fare: 5),
  (minKm: 21, maxKm: 35, fare: 10),
  (minKm: 36, maxKm: 50, fare: 15),
  (minKm: 51, maxKm: 65, fare: 20),
  (minKm: 66, maxKm: 80, fare: 25),
  (minKm: 81, maxKm: 95, fare: 30),
  (minKm: 96, maxKm: 110, fare: 35),
  (minKm: 111, maxKm: 125, fare: 40),
  (minKm: 126, maxKm: 150, fare: 45),
  (minKm: 151, maxKm: 9999, fare: 50),
];

/// O(1) amortised via a fixed-size sorted array — just 10 slabs.
int _slabFare(double distanceKm) {
  final km = distanceKm.ceil();
  for (final slab in _fareSlabs) {
    if (km <= slab.maxKm) return slab.fare;
  }
  return _fareSlabs.last.fare;
}

// ---------------------------------------------------------------------------
// Station & Edge Data
// ---------------------------------------------------------------------------

/// Each element: (fromCode, toCode, distanceKm)
/// Edges are bi-directional; we add both directions when building the graph.
const List<(String, String, double)> _edges = [
  // ── Western Line ─────────────────────────────────────────────
  ('CCG', 'MEL', 1.1),
  ('MEL', 'CYR', 1.2),
  ('CYR', 'GTR', 1.2),
  ('GTR', 'MMCT', 1.0),
  ('MMCT', 'MX', 1.4),
  ('MX', 'PL', 1.4),
  ('PL', 'PBHD', 1.4),
  ('PBHD', 'DDR', 1.6),
  ('DDR', 'MRU', 1.4),
  ('MRU', 'MM', 1.2),
  ('MM', 'BA', 1.8),
  ('BA', 'KHAR', 1.6),
  ('KHAR', 'STC', 1.6),
  ('STC', 'VLP', 2.0),
  ('VLP', 'ADH', 2.0),
  ('ADH', 'JOS', 2.2),
  ('JOS', 'RMAR', 1.3),
  ('RMAR', 'GMN', 1.4),
  ('GMN', 'MDD', 2.6),
  ('MDD', 'KILE', 1.7),
  ('KILE', 'BVI', 2.9),
  ('BVI', 'DIC', 2.4),
  ('DIC', 'MIRA', 3.1),
  ('MIRA', 'BYR', 3.5),
  ('BYR', 'NIG', 4.8),
  ('NIG', 'BSR', 4.0),
  ('BSR', 'NSP', 4.2),
  ('NSP', 'VR', 4.2),
  ('VR', 'VTN', 7.4),
  ('VTN', 'SPL', 5.0),
  ('SPL', 'KELVE', 5.5),
  ('KELVE', 'PLG', 3.6),
  ('PLG', 'BOR', 11.3),
  ('BOR', 'VGN', 10.9),
  ('VGN', 'DRD', 8.0),

  // ── Central Line ─────────────────────────────────────────────
  ('CSTM', 'MSD', 0.8),
  ('MSD', 'SND', 1.2),
  ('SND', 'BYC', 1.4),
  ('BYC', 'CNK', 1.0),
  ('CNK', 'CR', 1.0),
  ('CR', 'PRL', 1.0),
  ('PRL', 'DDR', 1.4), // DDR is an interchange with Western
  ('DDR', 'MTG', 1.6),
  ('MTG', 'SN', 1.4),
  ('SN', 'CLA', 2.0), // CLA = Kurla (interchange)
  ('CLA', 'VV', 1.2),
  ('VV', 'GC', 1.6), // GC = Ghatkopar
  ('GC', 'VK', 1.8),
  ('VK', 'KJM', 1.6),
  ('KJM', 'BND', 2.0),
  ('BND', 'NHR', 1.6),
  ('NHR', 'MLND', 1.6),
  ('MLND', 'TNA', 4.4), // TNA = Thane (interchange)
  ('TNA', 'KLW', 2.0),
  ('KLW', 'MMBR', 4.0),
  ('MMBR', 'DIVA', 3.0),
  ('DIVA', 'KPR', 1.4),
  ('KPR', 'DI', 2.4),
  ('DI', 'TKL', 2.6),
  ('TKL', 'KYN', 3.0),
  ('KYN', 'ABH', 8.0),
  ('ABH', 'BUD', 8.2),
  ('BUD', 'KJT', 34.0),
  ('KYN', 'TLA', 10.0),
  ('TLA', 'KSRA', 18.0),

  // ── Harbour Line CSTM → Panvel ────────────────────────────────
  ('CSTM', 'MSD', 0.8), // shared with Central
  ('MSD', 'SNDR', 1.2),
  ('SNDR', 'DKRD', 0.8),
  ('DKRD', 'REAY', 0.8),
  ('REAY', 'CTG', 0.8),
  ('CTG', 'SWR', 1.0),
  ('SWR', 'WR', 1.0),
  ('WR', 'GTBN', 1.2),
  ('GTBN', 'CHB', 1.2),
  ('CHB', 'CLA', 1.4), // CLA = Kurla (interchange)
  ('CLA', 'TLN', 1.4),
  ('TLN', 'CMBR', 1.8),
  ('CMBR', 'GV', 1.6),
  ('GV', 'MNKD', 1.8),
  ('MNKD', 'VSH', 4.2), // VSH = Vashi
  ('VSH', 'SNP', 1.4),
  ('SNP', 'JNR', 1.6),
  ('JNR', 'NEU', 2.2),
  ('NEU', 'SWD', 2.4),
  ('SWD', 'BEPR', 2.0),
  ('BEPR', 'KHAG', 2.6),
  ('KHAG', 'MNS', 2.4),
  ('MNS', 'KHD', 2.4),
  ('KHD', 'PNVL', 3.2),

  // ── Harbour Line Goregaon Branch (Wadala → Goregaon) ──────────
  ('WR', 'KRC', 1.6),
  ('KRC', 'MM', 1.4), // MM = Mahim (interchange with Western)
  ('MM', 'BA', 1.8), // BA = Bandra (shared with Western)
  ('BA', 'KHAR', 1.6),
  ('KHAR', 'STC', 1.6),
  ('STC', 'VLP', 2.0),
  ('VLP', 'ADH', 2.0), // ADH = Andheri (interchange)
  ('ADH', 'JOS', 2.2),
  ('JOS', 'GMN', 2.7), // GMN = Goregaon
];

const List<GraphStation> _stations = [
  // Western
  GraphStation(code: 'CCG', name: 'Churchgate', line: RailLine.western),
  GraphStation(code: 'MEL', name: 'Marine Lines', line: RailLine.western),
  GraphStation(code: 'CYR', name: 'Charni Road', line: RailLine.western),
  GraphStation(code: 'GTR', name: 'Grant Road', line: RailLine.western),
  GraphStation(code: 'MMCT', name: 'Mumbai Central', line: RailLine.western),
  GraphStation(code: 'MX', name: 'Mahalaxmi', line: RailLine.western),
  GraphStation(code: 'PL', name: 'Lower Parel', line: RailLine.western),
  GraphStation(code: 'PBHD', name: 'Prabhadevi', line: RailLine.western),
  GraphStation(code: 'DDR', name: 'Dadar', line: RailLine.western),
  GraphStation(code: 'MRU', name: 'Matunga Road', line: RailLine.western),
  GraphStation(code: 'MM', name: 'Mahim Junction', line: RailLine.western),
  GraphStation(code: 'BA', name: 'Bandra', line: RailLine.western),
  GraphStation(code: 'KHAR', name: 'Khar Road', line: RailLine.western),
  GraphStation(code: 'STC', name: 'Santacruz', line: RailLine.western),
  GraphStation(code: 'VLP', name: 'Vile Parle', line: RailLine.western),
  GraphStation(code: 'ADH', name: 'Andheri', line: RailLine.western),
  GraphStation(code: 'JOS', name: 'Jogeshwari', line: RailLine.western),
  GraphStation(code: 'RMAR', name: 'Ram Mandir', line: RailLine.western),
  GraphStation(code: 'GMN', name: 'Goregaon', line: RailLine.western),
  GraphStation(code: 'MDD', name: 'Malad', line: RailLine.western),
  GraphStation(code: 'KILE', name: 'Kandivali', line: RailLine.western),
  GraphStation(code: 'BVI', name: 'Borivali', line: RailLine.western),
  GraphStation(code: 'DIC', name: 'Dahisar', line: RailLine.western),
  GraphStation(code: 'MIRA', name: 'Mira Road', line: RailLine.western),
  GraphStation(code: 'BYR', name: 'Bhayandar', line: RailLine.western),
  GraphStation(code: 'NIG', name: 'Naigaon', line: RailLine.western),
  GraphStation(code: 'BSR', name: 'Vasai Road', line: RailLine.western),
  GraphStation(code: 'NSP', name: 'Nallasopara', line: RailLine.western),
  GraphStation(code: 'VR', name: 'Virar', line: RailLine.western),
  GraphStation(code: 'VTN', name: 'Vaitarna', line: RailLine.western),
  GraphStation(code: 'SPL', name: 'Saphale', line: RailLine.western),
  GraphStation(code: 'KELVE', name: 'Kelve Road', line: RailLine.western),
  GraphStation(code: 'PLG', name: 'Palghar', line: RailLine.western),
  GraphStation(code: 'BOR', name: 'Boisar', line: RailLine.western),
  GraphStation(code: 'VGN', name: 'Vangaon', line: RailLine.western),
  GraphStation(code: 'DRD', name: 'Dahanu Road', line: RailLine.western),

  // Central
  GraphStation(
    code: 'CSTM',
    name: 'Chhatrapati Shivaji Maharaj Terminus',
    line: RailLine.central,
  ),
  GraphStation(code: 'MSD', name: 'Masjid', line: RailLine.central),
  GraphStation(code: 'SND', name: 'Sandhurst Road', line: RailLine.central),
  GraphStation(code: 'BYC', name: 'Byculla', line: RailLine.central),
  GraphStation(code: 'CNK', name: 'Chinchpokli', line: RailLine.central),
  GraphStation(code: 'CR', name: 'Currey Road', line: RailLine.central),
  GraphStation(code: 'PRL', name: 'Parel', line: RailLine.central),
  // DDR = Dadar (shared with Western — same node)
  GraphStation(code: 'MTG', name: 'Matunga', line: RailLine.central),
  GraphStation(code: 'SN', name: 'Sion', line: RailLine.central),
  GraphStation(code: 'CLA', name: 'Kurla', line: RailLine.central),
  GraphStation(code: 'VV', name: 'Vidyavihar', line: RailLine.central),
  GraphStation(code: 'GC', name: 'Ghatkopar', line: RailLine.central),
  GraphStation(code: 'VK', name: 'Vikhroli', line: RailLine.central),
  GraphStation(code: 'KJM', name: 'Kanjurmarg', line: RailLine.central),
  GraphStation(code: 'BND', name: 'Bhandup', line: RailLine.central),
  GraphStation(code: 'NHR', name: 'Nahur', line: RailLine.central),
  GraphStation(code: 'MLND', name: 'Mulund', line: RailLine.central),
  GraphStation(code: 'TNA', name: 'Thane', line: RailLine.central),
  GraphStation(code: 'KLW', name: 'Kalwa', line: RailLine.central),
  GraphStation(code: 'MMBR', name: 'Mumbra', line: RailLine.central),
  GraphStation(code: 'DIVA', name: 'Diva', line: RailLine.central),
  GraphStation(code: 'KPR', name: 'Kopar', line: RailLine.central),
  GraphStation(code: 'DI', name: 'Dombivli', line: RailLine.central),
  GraphStation(code: 'TKL', name: 'Thakurli', line: RailLine.central),
  GraphStation(code: 'KYN', name: 'Kalyan Junction', line: RailLine.central),
  GraphStation(code: 'ABH', name: 'Ambernath', line: RailLine.central),
  GraphStation(code: 'BUD', name: 'Badlapur', line: RailLine.central),
  GraphStation(code: 'KJT', name: 'Karjat', line: RailLine.central),
  GraphStation(code: 'TLA', name: 'Titwala', line: RailLine.central),
  GraphStation(code: 'KSRA', name: 'Kasara', line: RailLine.central),

  // Harbour
  GraphStation(code: 'SNDR', name: 'Sandhurst Road', line: RailLine.harbour),
  GraphStation(code: 'DKRD', name: 'Dockyard Road', line: RailLine.harbour),
  GraphStation(code: 'REAY', name: 'Reay Road', line: RailLine.harbour),
  GraphStation(code: 'CTG', name: 'Cotton Green', line: RailLine.harbour),
  GraphStation(code: 'SWR', name: 'Sewri', line: RailLine.harbour),
  GraphStation(code: 'WR', name: 'Wadala Road', line: RailLine.harbour),
  GraphStation(
    code: 'GTBN',
    name: 'Guru Tegh Bahadur Nagar',
    line: RailLine.harbour,
  ),
  GraphStation(code: 'CHB', name: 'Chunabhatti', line: RailLine.harbour),
  GraphStation(code: 'TLN', name: 'Tilak Nagar', line: RailLine.harbour),
  GraphStation(code: 'CMBR', name: 'Chembur', line: RailLine.harbour),
  GraphStation(code: 'GV', name: 'Govandi', line: RailLine.harbour),
  GraphStation(code: 'MNKD', name: 'Mankhurd', line: RailLine.harbour),
  GraphStation(code: 'VSH', name: 'Vashi', line: RailLine.harbour),
  GraphStation(code: 'SNP', name: 'Sanpada', line: RailLine.harbour),
  GraphStation(code: 'JNR', name: 'Juinagar', line: RailLine.harbour),
  GraphStation(code: 'NEU', name: 'Nerul', line: RailLine.harbour),
  GraphStation(code: 'SWD', name: 'Seawoods–Darave', line: RailLine.harbour),
  GraphStation(code: 'BEPR', name: 'Belapur CBD', line: RailLine.harbour),
  GraphStation(code: 'KHAG', name: 'Kharghar', line: RailLine.harbour),
  GraphStation(code: 'MNS', name: 'Mansarovar', line: RailLine.harbour),
  GraphStation(code: 'KHD', name: 'Khandeshwar', line: RailLine.harbour),
  GraphStation(code: 'PNVL', name: 'Panvel', line: RailLine.harbour),
  GraphStation(code: 'KRC', name: "King's Circle", line: RailLine.harbour),
];

/// Stations where cross-line interchange is possible.
const Set<String> _interchangeCodes = {
  'DDR', // Dadar — Western ↔ Central
  'CLA', // Kurla — Central ↔ Harbour
  'BA', // Bandra — Western ↔ Harbour
  'ADH', // Andheri — Western ↔ Harbour
  'TNA', // Thane — Central (main interchange hub)
  'WR', // Wadala Road — Harbour
  'PNVL', // Panvel — Harbour terminal
};

// ---------------------------------------------------------------------------
// FareCalculatorService — Dijkstra-based fare calculator
// ---------------------------------------------------------------------------

class FareCalculatorService {
  FareCalculatorService._() {
    _build();
  }

  static final FareCalculatorService instance = FareCalculatorService._();

  // adjacency list: code → list of (neighbourCode, distanceKm)
  final Map<String, List<(String, double)>> _graph = {};
  final Map<String, GraphStation> _stationMap = {};

  void _build() {
    for (final s in _stations) {
      _stationMap.putIfAbsent(s.code, () => s);
      _graph.putIfAbsent(s.code, () => []);
    }

    for (final (from, to, dist) in _edges) {
      _graph.putIfAbsent(from, () => []);
      _graph.putIfAbsent(to, () => []);
      _graph[from]!.add((to, dist));
      _graph[to]!.add((from, dist)); // bi-directional
    }
  }

  /// Looks up a station by its code. Null if not found.
  GraphStation? stationByCode(String code) => _stationMap[code.toUpperCase()];

  /// Runs Dijkstra's algorithm to find the shortest path (by distance).
  /// Returns a [FareResult] or null if either code is invalid / no path exists.
  FareResult? calculate(String srcCode, String destCode) {
    final src = _stationMap[srcCode.toUpperCase()];
    final dest = _stationMap[destCode.toUpperCase()];

    if (src == null || dest == null) return null;
    if (src.code == dest.code) {
      return FareResult(
        source: src.name,
        destination: dest.name,
        route: [src.name],
        totalDistanceKm: 0.0,
        secondClassFare: 0,
        interchanges: [],
      );
    }

    // dist map
    final dist = <String, double>{};
    final prev = <String, String?>{};
    for (final code in _graph.keys) {
      dist[code] = double.infinity;
      prev[code] = null;
    }
    dist[src.code] = 0.0;

    // Min-priority queue implemented with SplayTreeMap (dart:collection).
    // Key format: "<dist padded>|<stationCode>" — ensures correct sort order.
    String _pqKey(double d, String code) =>
        '${d.toStringAsFixed(6).padLeft(20, '0')}|$code';

    final pq = SplayTreeMap<String, (double, String)>();
    pq[_pqKey(0.0, src.code)] = (0.0, src.code);

    while (pq.isNotEmpty) {
      final firstKey = pq.firstKey()!;
      final (d, u) = pq.remove(firstKey)!;
      if (d > (dist[u] ?? double.infinity)) continue;
      if (u == dest.code) break;

      for (final (String v, double weight)
          in (_graph[u] ?? <(String, double)>[])) {
        final newDist = d + weight;
        if (newDist < (dist[v] ?? double.infinity)) {
          dist[v] = newDist;
          prev[v] = u;
          pq[_pqKey(newDist, v)] = (newDist, v);
        }
      }
    }

    if ((dist[dest.code] ?? double.infinity) == double.infinity) return null;

    // Reconstruct path
    final path = <String>[];
    String? current = dest.code;
    while (current != null) {
      path.insert(0, current);
      current = prev[current];
    }

    final totalDist = double.parse((dist[dest.code] ?? 0.0).toStringAsFixed(1));

    final routeNames = path
        .map((c) => _stationMap[c]?.name ?? c)
        .toList(growable: false);

    final interchanges = path
        .where(
          (c) =>
              _interchangeCodes.contains(c) && c != src.code && c != dest.code,
        )
        .map((c) => _stationMap[c]?.name ?? c)
        .toList(growable: false);

    return FareResult(
      source: src.name,
      destination: dest.name,
      route: routeNames,
      totalDistanceKm: totalDist,
      secondClassFare: _slabFare(totalDist),
      interchanges: interchanges,
    );
  }
}
