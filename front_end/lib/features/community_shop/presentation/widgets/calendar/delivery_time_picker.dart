import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DeliveryTimePicker extends StatefulWidget {
  final Function(DateTime selectedDateTime) onTimeSelected;

  const DeliveryTimePicker({
    Key? key,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<DeliveryTimePicker> createState() => _DeliveryTimePickerState();
}

class _DeliveryTimePickerState extends State<DeliveryTimePicker>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Date selection
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Time selection
  int _selectedHour = 9; // Default to 9 AM
  int _selectedMinute = 0;

  // Time range
  final List<int> _hours =
      List.generate(10, (index) => index + 9); // 9 AM to 6 PM
  final List<int> _minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  // Fixed controller positions for initial values
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for French locale
    initializeDateFormatting('fr_FR', null);

    _tabController = TabController(length: 2, vsync: this);

    // Initialize scroll controllers with default positions
    _hourController = FixedExtentScrollController(initialItem: 0); // 9 AM
    _minuteController =
        FixedExtentScrollController(initialItem: 0); // 00 minutes
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  Widget _formatSelectedDateTime() {
    final date = DateFormat('d MMM yyyy', 'fr_FR').format(_selectedDay);
    final hour = _selectedHour.toString().padLeft(2, '0');
    final minute = _selectedMinute.toString().padLeft(2, '0');

    return RichText(
      text: TextSpan(
        text: 'Vous commencer le ',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: '$date ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const TextSpan(
            text: 'à ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: '$hour:$minute',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with tabs
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Programmer la commande',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 8.0),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.primary,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[700],
                      labelPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      tabs: const [
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              'Jour',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.0),
                            child: Text(
                              'Heure',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          SizedBox(
            height: 350, // Fixed height for tab content
            child: TabBarView(
              controller: _tabController,
              children: [
                // Day tab - Calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TableCalendar<dynamic>(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    locale: 'fr_FR', // French locale
                    selectedDayPredicate: (day) {
                      return day.year == _selectedDay.year &&
                          day.month == _selectedDay.month &&
                          day.day == _selectedDay.day;
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color(0xFFBBDEFB), // Light blue color
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Hour tab - Time picker
                Container(
                  color: Colors.white, // Dark background like iOS picker
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Selected time display with labels
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_selectedHour.toString().padLeft(2, '0')} heure',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              ':',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedMinute.toString().padLeft(2, '0')} min',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      // Time picker wheels with highlight container
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Highlight container for selected values
                          Container(
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          // Time pickers
                          SizedBox(
                            height: 200,
                            child: Row(
                              children: [
                                // Hours picker
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    controller: _hourController,
                                    itemExtent: 50,
                                    perspective: 0.005,
                                    diameterRatio: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (index) {
                                      setState(() {
                                        _selectedHour =
                                            _hours[index % _hours.length];
                                      });
                                    },
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                      builder: (context, index) {
                                        final hour =
                                            _hours[index % _hours.length];
                                        return Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            hour.toString().padLeft(2, '0'),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: _selectedHour == hour
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: _selectedHour == hour
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: _hours.length,
                                    ),
                                  ),
                                ),

                                // Separator
                                Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    ':',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 24),
                                  ),
                                ),

                                // Minutes picker
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    controller: _minuteController,
                                    itemExtent: 50,
                                    perspective: 0.005,
                                    diameterRatio: 1.2,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (index) {
                                      setState(() {
                                        _selectedMinute =
                                            _minutes[index % _minutes.length];
                                      });
                                    },
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                      builder: (context, index) {
                                        final minute =
                                            _minutes[index % _minutes.length];
                                        return Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            minute.toString().padLeft(2, '0'),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight:
                                                  _selectedMinute == minute
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              color: _selectedMinute == minute
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: _minutes.length,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Summary section at bottom (shared between tabs)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Summary text
                _formatSelectedDateTime(),
                const SizedBox(height: 16),

                // Confirm button
                ElevatedButton(
                  onPressed: () {
                    final selectedDateTime = DateTime(
                      _selectedDay.year,
                      _selectedDay.month,
                      _selectedDay.day,
                      _selectedHour,
                      _selectedMinute,
                    );

                    widget.onTimeSelected(selectedDateTime);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textSecondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirmer',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
