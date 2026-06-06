enum MumbaiLocalLine { western, central, harbour }

class MumbaiLocalStation {
  const MumbaiLocalStation({
    required this.name,
    required this.lineTypes,
    this.shortForm,
  });

  final String name;
  final Map<MumbaiLocalLine, bool> lineTypes;
  final String? shortForm;

  bool get isFast => lineTypes.values.any((isFastStop) => isFastStop);

  String get displayName => shortForm != null ? '$name ($shortForm)' : name;

  String get fieldDisplayName =>
      shortForm != null ? '$shortForm - $name' : name;

  String get searchListTitle => shortForm != null
      ? '${name.toUpperCase()} - $shortForm'
      : name.toUpperCase();

  static const locationSubtitle = 'MUMBAI, MAHARASHTRA';

  String get displaySubtitle {
    return lineTypes.entries
        .map((entry) {
          final lineName = switch (entry.key) {
            MumbaiLocalLine.western => 'Western',
            MumbaiLocalLine.central => 'Central',
            MumbaiLocalLine.harbour => 'Harbour',
          };
          final typeLabel = entry.value ? '⭐ Fast' : 'Slow';
          return '$lineName · $typeLabel';
        })
        .join('  ·  ');
  }
}

abstract final class MumbaiLocalStations {
  static const _shortForms = {
    'Churchgate': 'CCG',
    'Marine Lines': 'MEL',
    'Charni Road': 'CYR',
    'Grant Road': 'GTR',
    'Mumbai Central': 'MMCT',
    'Dadar': 'DDR',
    'Bandra': 'BA',
    'Andheri': 'ADH',
    'Goregaon': 'GMN',
    'Malad': 'MDD',
    'Borivali': 'BVI',
    'Dahisar': 'DIC',
    'Mira Road': 'MIRA',
    'Bhayandar': 'BYR',
    'Vasai Road': 'BSR',
    'Nallasopara': 'NSP',
    'Virar': 'VR',
    'Palghar': 'PLG',
    'Boisar': 'BOR',
    'Dahanu Road': 'DRD',
    'Kurla': 'CLA',
    'Ghatkopar': 'GC',
    'Vikhroli': 'VK',
    'Bhandup': 'BND',
    'Mulund': 'MLND',
    'Thane': 'TNA',
    'Diva': 'DIVA',
    'Dombivli': 'DI',
    'Kalyan Junction': 'KYN',
    'Ambernath': 'ABH',
    'Badlapur': 'BUD',
    'Karjat': 'KJT',
    'Kasara': 'KSRA',
    'Titwala': 'TLA',
    'Chembur': 'CMBR',
    'Govandi': 'GV',
    'Mankhurd': 'MNKD',
    'Vashi': 'VSH',
    'Nerul': 'NEU',
    'Belapur CBD': 'BEPR',
    'Kharghar': 'KHAG',
    'Panvel': 'PNVL',
  };

  static const _rawEntries =
      <({String name, MumbaiLocalLine line, bool isFast})>[
        // Western Line
        (name: 'Churchgate', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Marine Lines', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Charni Road', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Grant Road', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Mumbai Central', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Mahalaxmi', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Lower Parel', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Prabhadevi', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Dadar', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Matunga Road', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Mahim Junction', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Bandra', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Khar Road', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Santacruz', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Vile Parle', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Andheri', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Jogeshwari', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Ram Mandir', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Goregaon', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Malad', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Kandivali', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Borivali', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Dahisar', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Mira Road', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Bhayandar', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Naigaon', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Vasai Road', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Nallasopara', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Virar', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Vaitarna', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Saphale', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Kelve Road', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Palghar', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Boisar', line: MumbaiLocalLine.western, isFast: true),
        (name: 'Vangaon', line: MumbaiLocalLine.western, isFast: false),
        (name: 'Dahanu Road', line: MumbaiLocalLine.western, isFast: true),

        // Central Line (CSMT → Kalyan)
        (
          name: 'Chhatrapati Shivaji Maharaj Terminus',
          line: MumbaiLocalLine.central,
          isFast: true,
        ),
        (name: 'Masjid', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Sandhurst Road', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Byculla', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Chinchpokli', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Currey Road', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Parel', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Dadar', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Matunga', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Sion', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Kurla', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Vidyavihar', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Ghatkopar', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Vikhroli', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Kanjurmarg', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Bhandup', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Nahur', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Mulund', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Thane', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Kalwa', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Mumbra', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Diva', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Kopar', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Dombivli', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Thakurli', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Kalyan Junction', line: MumbaiLocalLine.central, isFast: true),
        (name: 'Ambernath', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Badlapur', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Karjat', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Kasara', line: MumbaiLocalLine.central, isFast: false),
        (name: 'Titwala', line: MumbaiLocalLine.central, isFast: false),

        // Harbour Line — CSMT → Panvel (all slow)
        (
          name: 'Chhatrapati Shivaji Maharaj Terminus',
          line: MumbaiLocalLine.harbour,
          isFast: false,
        ),
        (name: 'Masjid', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Sandhurst Road', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Dockyard Road', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Reay Road', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Cotton Green', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Sewri', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Wadala Road', line: MumbaiLocalLine.harbour, isFast: false),
        (
          name: 'Guru Tegh Bahadur Nagar',
          line: MumbaiLocalLine.harbour,
          isFast: false,
        ),
        (name: 'Chunabhatti', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Kurla', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Tilak Nagar', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Chembur', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Govandi', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Mankhurd', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Vashi', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Sanpada', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Juinagar', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Nerul', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Seawoods–Darave', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Belapur CBD', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Kharghar', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Mansarovar', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Khandeshwar', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Panvel', line: MumbaiLocalLine.harbour, isFast: false),

        // Harbour Line — Goregaon Branch (all slow)
        (name: 'Wadala Road', line: MumbaiLocalLine.harbour, isFast: false),
        (name: "King's Circle", line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Mahim Junction', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Bandra', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Khar Road', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Santacruz', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Vile Parle', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Andheri', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Jogeshwari', line: MumbaiLocalLine.harbour, isFast: false),
        (name: 'Goregaon', line: MumbaiLocalLine.harbour, isFast: false),
      ];

  static final List<MumbaiLocalStation> all = _buildMergedList();

  static List<MumbaiLocalStation> search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return all;

    final lowerQuery = trimmed.toLowerCase();
    return all
        .where(
          (station) =>
              station.name.toLowerCase().contains(lowerQuery) ||
              (station.shortForm?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList(growable: false);
  }

  static List<MumbaiLocalStation> _buildMergedList() {
    final merged = <String, Map<MumbaiLocalLine, bool>>{};

    for (final entry in _rawEntries) {
      merged.putIfAbsent(entry.name, () => {});
      merged[entry.name]![entry.line] = entry.isFast;
    }

    final stations =
        merged.entries
            .map(
              (entry) => MumbaiLocalStation(
                name: entry.key,
                lineTypes: Map.unmodifiable(entry.value),
                shortForm: _shortForms[entry.key],
              ),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return List.unmodifiable(stations);
  }
}
