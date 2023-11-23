import 'package:alice/core/alice_core.dart';
import 'package:alice/helper/alice_alert_helper.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_menu_item.dart';
import 'package:alice/ui/page/alice_call_details_screen.dart';
import 'package:alice/ui/page/alice_stats_screen.dart';
import 'package:alice/ui/widget/alice_call_list_item_widget.dart';
import 'package:alice/utils/alice_constants.dart';
import 'package:flutter/material.dart';

class AliceCallsListScreen extends StatefulWidget {
  final AliceCore _aliceCore;

  const AliceCallsListScreen(this._aliceCore, {super.key});

  @override
  State<AliceCallsListScreen> createState() => _AliceCallsListScreenState();
}

class _AliceCallsListScreenState extends State<AliceCallsListScreen> {
  AliceCore get aliceCore => widget._aliceCore;
  bool _searchEnabled = false;
  final TextEditingController _queryTextEditingController =
      TextEditingController();
  final List<AliceMenuItem> _menuItems = [];

  _AliceCallsListScreenState() {
    _menuItems
      ..add(AliceMenuItem('Delete', Icons.delete))
      ..add(AliceMenuItem('Stats', Icons.insert_chart));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: false,
        brightness: widget._aliceCore.brightness,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              brightness: widget._aliceCore.brightness,
              primary: AliceConstants.strongRed,
              secondary: AliceConstants.lightRed,
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: _searchEnabled ? _buildSearchField() : _buildTitleWidget(),
          actions: [
            _buildSearchButton(),
            _buildMenuButton(),
          ],
        ),
        body: _buildCallsListWrapper(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _queryTextEditingController.dispose();
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: _onSearchClicked,
    );
  }

  void _onSearchClicked() {
    setState(() {
      _searchEnabled = !_searchEnabled;
      if (!_searchEnabled) {
        _queryTextEditingController.text = '';
      }
    });
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<AliceMenuItem>(
      onSelected: _onMenuItemSelected,
      itemBuilder: (BuildContext context) {
        return _menuItems.map((AliceMenuItem item) {
          return PopupMenuItem<AliceMenuItem>(
            value: item,
            child: Row(
              children: [
                Icon(
                  item.iconData,
                  color: AliceConstants.lightRed,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Text(item.title),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildTitleWidget() {
    return const Text('Alice - Inspector');
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _queryTextEditingController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search http request...',
        hintStyle: TextStyle(fontSize: 16, color: AliceConstants.grey),
        border: InputBorder.none,
      ),
      style: TextStyle(fontSize: 16, color: AliceConstants.white),
      cursorColor: AliceConstants.white,
      onChanged: _updateSearchQuery,
    );
  }

  void _onMenuItemSelected(AliceMenuItem menuItem) {
    if (menuItem.title == 'Delete') {
      _showRemoveDialog();
    }
    if (menuItem.title == 'Stats') {
      _showStatsScreen();
    }
  }

  Widget _buildCallsListWrapper() {
    return StreamBuilder<List<AliceHttpCall>>(
      stream: aliceCore.callsSubject,
      builder: (context, snapshot) {
        var calls = snapshot.data ?? [];
        final query = _queryTextEditingController.text.trim();
        if (query.isNotEmpty) {
          calls = calls
              .where(
                (call) =>
                    call.endpoint.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
        }
        if (calls.isNotEmpty) {
          return _buildCallsListWidget(calls);
        } else {
          return _buildEmptyWidget();
        }
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AliceConstants.orange,
            ),
            const SizedBox(height: 6),
            const Text(
              'There are no calls to show',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• Check if you send any http request',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '• Check your Alice configuration',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '• Check search filters',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallsListWidget(List<AliceHttpCall> calls) {
    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        return AliceCallListItemWidget(calls[index], _onListItemClicked);
      },
    );
  }

  void _onListItemClicked(AliceHttpCall call) {
    Navigator.push<void>(
      widget._aliceCore.getContext()!,
      MaterialPageRoute(
        builder: (context) => AliceCallDetailsScreen(call, widget._aliceCore),
      ),
    );
  }

  void _showRemoveDialog() {
    AliceAlertHelper.showAlert(
      context,
      'Delete calls',
      'Do you want to delete http calls?',
      firstButtonTitle: 'No',
      firstButtonAction: () => <String, dynamic>{},
      secondButtonTitle: 'Yes',
      secondButtonAction: _removeCalls,
    );
  }

  void _removeCalls() {
    aliceCore.removeCalls();
  }

  void _showStatsScreen() {
    Navigator.push<void>(
      aliceCore.getContext()!,
      MaterialPageRoute(
        builder: (context) => AliceStatsScreen(widget._aliceCore),
      ),
    );
  }

  void _updateSearchQuery(String query) {
    setState(() {});
  }
}
