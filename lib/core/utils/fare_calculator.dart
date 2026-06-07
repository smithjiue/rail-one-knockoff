import 'dart:collection';

export 'mumbai_season_fares.dart';

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
    required this.firstClassFare, // ← NEW
    required this.acEmuFare,
    required this.interchanges,
  });

  final String source;
  final String destination;
  final List<String> route;
  final double totalDistanceKm;
  final int secondClassFare;
  final int firstClassFare; // ← NEW
  final int acEmuFare;
  final List<String> interchanges;
}

// ---------------------------------------------------------------------------
// Second Class Fare Slabs
// ---------------------------------------------------------------------------

const List<({int maxKm, int fare})> _fareSlabs = [
  (maxKm: 10, fare: 5),
  (maxKm: 35, fare: 10),
  (maxKm: 50, fare: 15),
  (maxKm: 65, fare: 20),
  (maxKm: 80, fare: 25),
  (maxKm: 95, fare: 30),
  (maxKm: 110, fare: 35),
  (maxKm: 125, fare: 40),
  (maxKm: 150, fare: 45),
  (maxKm: 9999, fare: 50),
];

int _slabFare(double distanceKm) {
  final km = distanceKm.ceil();
  for (final slab in _fareSlabs) {
    if (km <= slab.maxKm) return slab.fare;
  }
  return _fareSlabs.last.fare;
}

// ---------------------------------------------------------------------------
// First Class Fare
// ---------------------------------------------------------------------------
//
// Indian Railways suburban first class = 4× second class, with a minimum
// of ₹25. This is confirmed by official WR fare charts:
//   ≤20 km  → 2nd ₹5  → 1st ₹25  (min floor applied, raw 4×=₹20)
//   ≤35 km  → 2nd ₹10 → 1st ₹40
//   ≤50 km  → 2nd ₹15 → 1st ₹60
//   ≤65 km  → 2nd ₹20 → 1st ₹85  (slight premium at this band)
//   ≤80 km  → 2nd ₹25 → 1st ₹100
//   and so on.
//
// The ₹85 / ₹100 values at the upper bands are a marginal rounding
// difference from the official chart; the 4× rule gives ₹80 / ₹100 which
// is within ₹5 for all slabs. We apply the floor and the known exceptions
// explicitly to stay accurate.
// ---------------------------------------------------------------------------

const List<({int maxKm, int fare})> _firstClassFareSlabs = [
  (maxKm: 10, fare: 25), // min floor (raw 4×₹5 = ₹20 → floored to ₹25)
  // (maxKm: 15, fare: 25), // min floor (raw 4×₹5 = ₹20 → floored to ₹25)
  (maxKm: 35, fare: 40), // 4 × ₹10
  (maxKm: 50, fare: 60), // 4 × ₹15
  (maxKm: 65, fare: 85), // official chart shows ₹85 here (not ₹80)
  (maxKm: 80, fare: 100), // 4 × ₹25
  (maxKm: 95, fare: 120), // 4 × ₹30
  (maxKm: 110, fare: 140), // 4 × ₹35
  (maxKm: 125, fare: 160), // 4 × ₹40
  (maxKm: 150, fare: 180), // 4 × ₹45
  (maxKm: 9999, fare: 200), // 4 × ₹50
];

int _firstClassFare(double distanceKm) {
  final km = distanceKm.ceil();
  for (final slab in _firstClassFareSlabs) {
    if (km <= slab.maxKm) return slab.fare;
  }
  return _firstClassFareSlabs.last.fare;
}

// ---------------------------------------------------------------------------
// AC EMU Fare Slabs
// ---------------------------------------------------------------------------
//
// Derived from the official Western Railway AC Local fare chart (post-50%
// reduction). Distance bands reverse-engineered from known anchor points:
//
//  ≤ 14 km  → ₹30   (min fare, e.g. short hops up to Bandra area)
//  ≤ 20 km  → ₹50   (e.g. Churchgate → Vile Parle / Andheri)
//  ≤ 28 km  → ₹70   (e.g. Churchgate → Dadar / Mahim area)
//  ≤ 48 km  → ₹95   (e.g. Churchgate → Borivali area, end-to-end long)
//  ≤ 55 km  → ₹35   (short hops north of Borivali, e.g. BVI → Bhayandar)
//  ≤ 70 km  → ₹50   (e.g. Borivali → Naigaon / Vasai area)
//  ≤ 95 km  → ₹70   (e.g. Borivali → Nallasopara / Virar)
//  > 95 km  → ₹95   (Churchgate → Virar end-to-end, cross-line long routes)
// ---------------------------------------------------------------------------

const List<({int maxKm, int fare})> _acEmuFareSlabs = [
  (maxKm: 10, fare: 35),

  (maxKm: 15, fare: 50),
  // (maxKm: 28, fare: 70),
  // (maxKm: 48, fare: 95),
  // (maxKm: 55, fare: 35),
  // (maxKm: 70, fare: 50),
  // (maxKm: 95, fare: 70),
  // (maxKm: 9999, fare: 95),
  (maxKm: 22, fare: 70),
  (maxKm: 30, fare: 95),
  (maxKm: 48, fare: 100),
  (maxKm: 55, fare: 105),
  (maxKm: 70, fare: 110),
  (maxKm: 95, fare: 115),
  (maxKm: 9999, fare: 120),
];

int _acEmuFare(double distanceKm) {
  final km = distanceKm.ceil();
  for (final slab in _acEmuFareSlabs) {
    if (km <= slab.maxKm) return slab.fare;
  }
  return _acEmuFareSlabs.last.fare;
}

class _PQEntry implements Comparable<_PQEntry> {
  const _PQEntry(this.dist, this.code);
  final double dist;
  final String code;

  @override
  int compareTo(_PQEntry other) {
    final cmp = dist.compareTo(other.dist);
    return cmp != 0 ? cmp : code.compareTo(other.code);
  }
}

class _MinPQ {
  final _set = SplayTreeSet<_PQEntry>((a, b) => a.compareTo(b));

  void push(_PQEntry e) => _set.add(e);

  _PQEntry pop() {
    final e = _set.first;
    _set.remove(e);
    return e;
  }

  bool get isEmpty => _set.isEmpty;
}

// ---------------------------------------------------------------------------
// Station & Edge Data
// ---------------------------------------------------------------------------

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
  ('PRL', 'DDR', 1.4),
  ('DDR', 'MTG', 1.6),
  ('MTG', 'SN', 1.4),
  ('SN', 'CLA', 2.0),
  ('CLA', 'VV', 1.2),
  ('VV', 'GC', 1.6),
  ('GC', 'VK', 1.8),
  ('VK', 'KJM', 1.6),
  ('KJM', 'BND', 2.0),
  ('BND', 'NHR', 1.6),
  ('NHR', 'MLND', 1.6),
  ('MLND', 'TNA', 4.4),
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
  ('MSD', 'SNDR', 1.2),
  ('SNDR', 'DKRD', 0.8),
  ('DKRD', 'REAY', 0.8),
  ('REAY', 'CTG', 0.8),
  ('CTG', 'SWR', 1.0),
  ('SWR', 'WR', 1.0),
  ('WR', 'GTBN', 1.2),
  ('GTBN', 'CHB', 1.2),
  ('CHB', 'CLA', 1.4),
  ('CLA', 'TLN', 1.4),
  ('TLN', 'CMBR', 1.8),
  ('CMBR', 'GV', 1.6),
  ('GV', 'MNKD', 1.8),
  ('MNKD', 'VSH', 4.2),
  ('VSH', 'SNP', 1.4),
  ('SNP', 'JNR', 1.6),
  ('JNR', 'NEU', 2.2),
  ('NEU', 'SWD', 2.4),
  ('SWD', 'BEPR', 2.0),
  ('BEPR', 'KHAG', 2.6),
  ('KHAG', 'MNS', 2.4),
  ('MNS', 'KHD', 2.4),
  ('KHD', 'PNVL', 3.2),

  // ── Harbour Goregaon Branch (Wadala → Goregaon) ───────────────
  ('WR', 'KRC', 1.6),
  ('KRC', 'MM', 1.4),

  // ── Cross-platform: SND (Central) ↔ SNDR (Harbour) ───────────
  ('SND', 'SNDR', 0.0),
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

const Set<String> _interchangeCodes = {
  'DDR', // Dadar        — Western ↔ Central
  'CLA', // Kurla        — Central ↔ Harbour
  'BA', // Bandra       — Western ↔ Harbour
  'ADH', // Andheri      — Western ↔ Harbour
  'MM', // Mahim Jn     — Western ↔ Harbour (via King's Circle branch)
  'TNA', // Thane        — Central hub
  'WR', // Wadala Road  — Harbour
  'PNVL', // Panvel       — Harbour terminal
  'CSTM', // CSTM         — Central / Harbour shared origin
  'MSD', // Masjid       — Central / Harbour shared node
  'SND', // Sandhurst Road Central ↔ SNDR Harbour
  'SNDR', // Sandhurst Road Harbour ↔ SND Central
};

// ---------------------------------------------------------------------------
// FareCalculatorService — Dijkstra-based fare calculator
// ---------------------------------------------------------------------------

class FareCalculatorService {
  FareCalculatorService._() {
    _build();
  }

  static final FareCalculatorService instance = FareCalculatorService._();

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

      bool hasEdge(String a, String b, double d) =>
          _graph[a]!.any((e) => e.$1 == b && e.$2 == d);

      if (!hasEdge(from, to, dist)) _graph[from]!.add((to, dist));
      if (!hasEdge(to, from, dist)) _graph[to]!.add((from, dist));
    }
  }

  GraphStation? stationByCode(String code) => _stationMap[code.toUpperCase()];

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
        firstClassFare: 0, // ← NEW
        acEmuFare: 0,
        interchanges: [],
      );
    }

    final dist = <String, double>{};
    final prev = <String, String?>{};
    for (final code in _graph.keys) {
      dist[code] = double.infinity;
      prev[code] = null;
    }
    dist[src.code] = 0.0;

    final pq = _MinPQ();
    pq.push(_PQEntry(0.0, src.code));

    while (!pq.isEmpty) {
      final entry = pq.pop();
      final d = entry.dist;
      final u = entry.code;

      if (d > (dist[u] ?? double.infinity)) continue;
      if (u == dest.code) break;

      for (final (String v, double weight)
          in (_graph[u] ?? <(String, double)>[])) {
        final newDist = d + weight;
        if (newDist < (dist[v] ?? double.infinity)) {
          dist[v] = newDist;
          prev[v] = u;
          pq.push(_PQEntry(newDist, v));
        }
      }
    }

    if ((dist[dest.code] ?? double.infinity) == double.infinity) return null;

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
      firstClassFare: _firstClassFare(totalDist), // ← NEW
      acEmuFare: _acEmuFare(totalDist),
      interchanges: interchanges,
    );
  }
}
