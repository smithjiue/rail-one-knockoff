import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/constants/mumbai_local_stations.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class SearchStationPage extends StatefulWidget {
  const SearchStationPage({super.key, required this.fieldLabel});

  final String fieldLabel;

  @override
  State<SearchStationPage> createState() => _SearchStationPageState();
}

class _SearchStationPageState extends State<SearchStationPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<MumbaiLocalStation> get _searchResults {
    return MumbaiLocalStations.search(_searchController.text);
  }

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  void _selectStation(MumbaiLocalStation station) {
    Navigator.of(context).pop(station);
  }

  Widget _buildStationTile(MumbaiLocalStation station) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectStation(station),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.searchListTitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.logoDark,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 4),
              Text(
                MumbaiLocalStation.locationSubtitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.authHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsDropdown(List<MumbaiLocalStation> listItems) {
    return Container(
      constraints: BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: Color(0xFFFEF7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: listItems.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Text(
                'No stations found',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.authHint,
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: listItems.length,
              separatorBuilder: (_, __) => SizedBox(height: 4),
              itemBuilder: (context, index) {
                return _buildStationTile(listItems[index]);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listItems = _isSearching
        ? _searchResults
        : const <MumbaiLocalStation>[];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Search Station',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authPrimaryDark,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: AppColors.borderLight),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 32, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fieldLabel,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authPrimaryDark,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: AppColors.cyanBlue),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: AppColors.authFieldIcon,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.logoDark,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                hintText: 'Select Station',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.authHint,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.mic_none_rounded,
                            size: 22,
                            color: AppColors.authFieldIcon,
                          ),
                        ],
                      ),
                    ),
                    if (_isSearching) _buildSearchResultsDropdown(listItems),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
