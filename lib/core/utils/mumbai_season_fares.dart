// Mumbai suburban season pass monthly fares aligned with Rail One / UTS charts.

import 'dart:math';

enum SeasonTicketDuration { monthly, quarterly, halfYearly, yearly }

enum SeasonTravelCategory { secondClass, firstClass, acEmu }

/// AC EMU monthly pass from Churchgate (Rail One / mumbai7 chart).
const Map<String, int> _acMonthlyFromChurchgate = {
  'CCG': 620,
  'MEL': 620,
  'CYR': 620,
  'GTR': 620,
  'MMCT': 620,
  'MX': 620,
  'PL': 620,
  'PBHD': 620,
  'DDR': 885,
  'MRU': 885,
  'MM': 885,
  'BA': 885,
  'KHAR': 1325,
  'STC': 1325,
  'VLP': 1325,
  'ADH': 1335,
  'JOS': 1335,
  'RMAR': 1765,
  'GMN': 1765,
  'MDD': 1765,
  'KILE': 1765,
  'BVI': 1775,
  'DIC': 1870,
  'MIRA': 1870,
  'BYR': 1880,
  'NIG': 2050,
  'BSR': 2135,
  'NSP': 2205,
  'VR': 2205,
  'VTN': 6465,
  'SPL': 6865,
  'KELVE': 7345,
  'PLG': 7460,
  'BOR': 7885,
  'VGN': 8120,
  'DRD': 8770,
};

/// AC EMU monthly pass from CSMT (Central / Harbour anchors from Rail One).
const Map<String, int> _acMonthlyFromCsmt = {
  'CSTM': 620,
  'MSD': 620,
  'SND': 620,
  'BYC': 620,
  'CNK': 620,
  'CR': 620,
  'PRL': 620,
  'DDR': 885,
  'MTG': 885,
  'SN': 885,
  'CLA': 885,
  'VV': 885,
  'GC': 885,
  'VK': 1325,
  'KJM': 1325,
  'BND': 1325,
  'NHR': 1325,
  'MLND': 1325,
  'TNA': 1900,
  'KLW': 1900,
  'MMBR': 1900,
  'DIVA': 1900,
  'KPR': 2050,
  'DI': 2050,
  'TKL': 2050,
  'KYN': 2135,
  'ABH': 2405,
  'BUD': 2405,
  'KJT': 2910,
  'KSRA': 3235,
  'TLA': 2405,
  // Harbour
  'DKRD': 620,
  'REAY': 620,
  'CTG': 620,
  'SWR': 620,
  'WR': 620,
  'GTBN': 885,
  'KRC': 885,
  'CHM': 885,
  'GDB': 885,
  'MANK': 1325,
  'VSH': 1765,
  'SNP': 1900,
  'JNJ': 1900,
  'NRL': 1900,
  'SEW': 1900,
  'CBD': 2050,
  'BEPR': 2135,
  'KHAG': 2135,
  'MNS': 2135,
  'KHD': 2225,
  'PNVL': 2225,
};

/// Second class ordinary monthly pass from CSMT (mumbai7 chart).
const Map<String, int> _secondClassMonthlyFromCsmt = {
  'CSTM': 100,
  'MSD': 100,
  'SND': 100,
  'BYC': 100,
  'CNK': 100,
  'CR': 100,
  'PRL': 100,
  'DDR': 100,
  'MTG': 130,
  'SN': 130,
  'CLA': 130,
  'VV': 130,
  'GC': 130,
  'VK': 215,
  'KJM': 215,
  'BND': 215,
  'NHR': 215,
  'MLND': 215,
  'TNA': 215,
  'KLW': 215,
  'MMBR': 215,
  'DIVA': 215,
  'KPR': 300,
  'DI': 300,
  'TKL': 300,
  'KYN': 315,
  'ABH': 315,
  'BUD': 315,
  'TLA': 315,
  'KJT': 400,
  'KSRA': 500,
  // Western extension from Dadar (same chart zones)
  'MRU': 130,
  'MM': 130,
  'BA': 130,
  'KHAR': 130,
  'STC': 130,
  'VLP': 130,
  'ADH': 215,
  'JOS': 215,
  'RMAR': 215,
  'GMN': 215,
  'MDD': 215,
  'KILE': 215,
  'BVI': 215,
  'DIC': 215,
  'MIRA': 215,
  'BYR': 300,
  'NIG': 315,
  'BSR': 315,
  'NSP': 315,
  'VR': 315,
  'VTN': 315,
  'SPL': 400,
  'KELVE': 400,
  'PLG': 400,
  'BOR': 500,
  'VGN': 500,
  'DRD': 500,
  // Harbour
  'DKRD': 100,
  'REAY': 100,
  'CTG': 100,
  'SWR': 100,
  'WR': 100,
  'GTBN': 130,
  'KRC': 130,
  'CHM': 130,
  'GDB': 130,
  'MANK': 215,
  'VSH': 265,
  'SNP': 265,
  'JNJ': 265,
  'NRL': 265,
  'SEW': 265,
  'CBD': 265,
  'BEPR': 285,
  'KHAG': 285,
  'MNS': 285,
  'KHD': 370,
  'PNVL': 370,
  // Churchgate end (short zone)
  'CCG': 100,
  'MEL': 100,
  'CYR': 100,
  'GTR': 100,
  'MMCT': 100,
  'MX': 100,
  'PL': 100,
  'PBHD': 100,
};

/// First class ordinary monthly pass from CSMT (mumbai7 chart).
const Map<String, int> _firstClassMonthlyFromCsmt = {
  'CSTM': 345,
  'MSD': 345,
  'SND': 345,
  'BYC': 345,
  'CNK': 345,
  'CR': 345,
  'PRL': 345,
  'DDR': 345,
  'MTG': 490,
  'SN': 490,
  'CLA': 570,
  'VV': 570,
  'GC': 570,
  'VK': 660,
  'KJM': 660,
  'BND': 670,
  'NHR': 670,
  'MLND': 755,
  'TNA': 755,
  'KLW': 825,
  'MMBR': 825,
  'DIVA': 825,
  'KPR': 990,
  'DI': 990,
  'TKL': 990,
  'KYN': 1105,
  'ABH': 1185,
  'BUD': 1280,
  'TLA': 1195,
  'KJT': 1695,
  'KSRA': 1995,
  'MRU': 490,
  'MM': 490,
  'BA': 490,
  'KHAR': 490,
  'STC': 570,
  'VLP': 570,
  'ADH': 660,
  'JOS': 660,
  'RMAR': 670,
  'GMN': 670,
  'MDD': 670,
  'KILE': 670,
  'BVI': 755,
  'DIC': 825,
  'MIRA': 825,
  'BYR': 910,
  'NIG': 990,
  'BSR': 1105,
  'NSP': 1105,
  'VR': 1185,
  'VTN': 1280,
  'SPL': 1440,
  'KELVE': 1525,
  'PLG': 1605,
  'BOR': 1815,
  'VGN': 1905,
  'DRD': 1995,
  'CCG': 345,
  'MEL': 345,
  'CYR': 345,
  'GTR': 345,
  'MMCT': 345,
  'MX': 345,
  'PL': 345,
  'PBHD': 345,
  'DKRD': 345,
  'REAY': 345,
  'CTG': 345,
  'SWR': 345,
  'WR': 345,
  'GTBN': 490,
  'KRC': 490,
  'CHM': 490,
  'GDB': 490,
  'MANK': 660,
  'VSH': 800,
  'SNP': 885,
  'JNJ': 885,
  'NRL': 885,
  'SEW': 885,
  'CBD': 960,
  'BEPR': 1085,
  'KHAG': 1085,
  'MNS': 1085,
  'KHD': 1165,
  'PNVL': 1165,
};

const Set<String> _westernCodes = {
  'CCG',
  'MEL',
  'CYR',
  'GTR',
  'MMCT',
  'MX',
  'PL',
  'PBHD',
  'DDR',
  'MRU',
  'MM',
  'BA',
  'KHAR',
  'STC',
  'VLP',
  'ADH',
  'JOS',
  'RMAR',
  'GMN',
  'MDD',
  'KILE',
  'BVI',
  'DIC',
  'MIRA',
  'BYR',
  'NIG',
  'BSR',
  'NSP',
  'VR',
  'VTN',
  'SPL',
  'KELVE',
  'PLG',
  'BOR',
  'VGN',
  'DRD',
};

double _seasonDurationMultiplier(SeasonTicketDuration duration) =>
    switch (duration) {
      SeasonTicketDuration.monthly => 1.0,
      SeasonTicketDuration.quarterly => 2.7,
      SeasonTicketDuration.halfYearly => 5.4,
      SeasonTicketDuration.yearly => 10.8,
    };

int? _chartFare(String code, Map<String, int> chart) =>
    chart[code.toUpperCase()];

int _terminalChartFare({
  required String sourceCode,
  required String destinationCode,
  required Map<String, int> chart,
  required String terminalCode,
}) {
  final src = sourceCode.toUpperCase();
  final dest = destinationCode.toUpperCase();
  final terminal = terminalCode.toUpperCase();

  if (src == dest) return 0;

  final srcFare = _chartFare(src, chart);
  final destFare = _chartFare(dest, chart);

  if (src == terminal && destFare != null) return destFare;
  if (dest == terminal && srcFare != null) return srcFare;

  return 0;
}

int _betweenStationsChartFare({
  required String sourceCode,
  required String destinationCode,
  required Map<String, int> chart,
}) {
  final srcFare = _chartFare(sourceCode, chart);
  final destFare = _chartFare(destinationCode, chart);
  if (srcFare == null || destFare == null) return 0;
  // Rail One uses the inner (closer-to-terminal) station chart value.
  return min(srcFare, destFare);
}

({Map<String, int> chart, String terminal}) _pickSeasonChart({
  required String sourceCode,
  required String destinationCode,
  required SeasonTravelCategory category,
}) {
  final src = sourceCode.toUpperCase();
  final dest = destinationCode.toUpperCase();
  final srcWestern = _westernCodes.contains(src);
  final destWestern = _westernCodes.contains(dest);

  if (category == SeasonTravelCategory.acEmu) {
    if (srcWestern && destWestern) {
      return (chart: _acMonthlyFromChurchgate, terminal: 'CCG');
    }
    return (chart: _acMonthlyFromCsmt, terminal: 'CSTM');
  }

  if (category == SeasonTravelCategory.firstClass) {
    if (srcWestern && destWestern) {
      return (chart: _firstClassMonthlyFromCsmt, terminal: 'CCG');
    }
    return (chart: _firstClassMonthlyFromCsmt, terminal: 'CSTM');
  }

  if (srcWestern && destWestern) {
    return (chart: _secondClassMonthlyFromCsmt, terminal: 'CCG');
  }

  return (chart: _secondClassMonthlyFromCsmt, terminal: 'CSTM');
}

int _resolveMonthlySeasonFare({
  required String sourceCode,
  required String destinationCode,
  required SeasonTravelCategory category,
}) {
  final src = sourceCode.toUpperCase();
  final dest = destinationCode.toUpperCase();
  final chartInfo = _pickSeasonChart(
    sourceCode: sourceCode,
    destinationCode: destinationCode,
    category: category,
  );

  // Rail One uses terminal charts when either station is the line origin.
  if (src == chartInfo.terminal || dest == chartInfo.terminal) {
    final terminalFare = _terminalChartFare(
      sourceCode: sourceCode,
      destinationCode: destinationCode,
      chart: chartInfo.chart,
      terminalCode: chartInfo.terminal,
    );
    if (terminalFare > 0) return terminalFare;
  }

  return _betweenStationsChartFare(
    sourceCode: sourceCode,
    destinationCode: destinationCode,
    chart: chartInfo.chart,
  );
}

int calculateSeasonFare({
  required String sourceCode,
  required String destinationCode,
  required SeasonTravelCategory category,
  required SeasonTicketDuration duration,
}) {
  final monthly = _resolveMonthlySeasonFare(
    sourceCode: sourceCode,
    destinationCode: destinationCode,
    category: category,
  );

  if (monthly <= 0) return 0;

  return (monthly * _seasonDurationMultiplier(duration)).round();
}
