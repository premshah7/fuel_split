import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../trips/repositories/trip_repository.dart';
import '../../../core/theme/theme_provider.dart';

enum ChartFilter { fiveDays, weekly, monthly }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  ChartFilter _selectedFilter = ChartFilter.fiveDays;

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(allTripsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Dashboard',
              style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
            ),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggleTheme(isDark);
                },
              ),
              IconButton(
                icon: const Icon(Icons.local_gas_station_outlined),
                tooltip: 'Fuel Logs',
                onPressed: () => context.push('/fuel-logs'),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => context.push('/profile'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          tripsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
            data: (trips) {
              if (trips.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.insert_chart_outlined_rounded, size: 64, color: theme.primaryColor),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        Text('No Analytics Yet', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Log some trips to see your spending trends and insights.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                );
              }

              final totalSpent = trips.fold(0.0, (sum, t) => sum + t.totalCost);
              final totalDistance = trips.fold(0.0, (sum, t) => sum + t.distance);
              final avgCostPerKm = totalDistance > 0 ? (totalSpent / totalDistance) : 0.0;

              // Time-series grouping logic
              final List<FlSpot> spots = [];
              final List<String> labels = [];

              if (_selectedFilter == ChartFilter.fiveDays) {
                for (int i = 4; i >= 0; i--) {
                  final date = DateTime.now().subtract(Duration(days: i));
                  final cost = trips.where((t) =>
                      t.tripDate.year == date.year &&
                      t.tripDate.month == date.month &&
                      t.tripDate.day == date.day
                  ).fold(0.0, (sum, t) => sum + t.totalCost);

                  spots.add(FlSpot((4 - i).toDouble(), cost));
                  labels.add(DateFormat('E').format(date));
                }
              } else if (_selectedFilter == ChartFilter.weekly) {
                for (int i = 6; i >= 0; i--) {
                  final date = DateTime.now().subtract(Duration(days: i));
                  final cost = trips.where((t) =>
                      t.tripDate.year == date.year &&
                      t.tripDate.month == date.month &&
                      t.tripDate.day == date.day
                  ).fold(0.0, (sum, t) => sum + t.totalCost);

                  spots.add(FlSpot((6 - i).toDouble(), cost));
                  labels.add(DateFormat('E').format(date));
                }
              } else if (_selectedFilter == ChartFilter.monthly) {
                for (int i = 5; i >= 0; i--) {
                  final date = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
                  final cost = trips.where((t) =>
                      t.tripDate.year == date.year &&
                      t.tripDate.month == date.month
                  ).fold(0.0, (sum, t) => sum + t.totalCost);

                  spots.add(FlSpot((5 - i).toDouble(), cost));
                  labels.add(DateFormat('MMM').format(date));
                }
              }

              // Compute dynamic Y scale
              final double maxVal = spots.map((s) => s.y).fold(0.0, (prev, y) => y > prev ? y : prev);
              final double maxY = maxVal > 0 ? (maxVal * 1.25) : 500.0;
              final double horizontalInterval = maxY > 0 ? (maxY / 5) : 100.0;

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(context, 'Total Spent', '₹${totalSpent.toStringAsFixed(0)}', Icons.account_balance_wallet_rounded).animate().fadeIn().slideY(begin: 0.1, end: 0)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(context, 'Distance', '${totalDistance.toStringAsFixed(0)} km', Icons.route_rounded).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(context, 'Trips Taken', '${trips.length}', Icons.directions_car_rounded).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(context, 'Avg. Cost/km', '₹${avgCostPerKm.toStringAsFixed(1)}', Icons.insights_rounded).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text('Spending Trend', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),

                    // Custom Segmented Control
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Row(
                        children: ChartFilter.values.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          final label = filter == ChartFilter.fiveDays ? '5 Days' : filter == ChartFilter.weekly ? 'Weekly' : 'Monthly';
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = filter),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isSelected && !isDark ? [
                                    BoxShadow(
                                      color: theme.primaryColor.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ] : null,
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ).animate().fadeIn(delay: 450.ms),
                    
                    const SizedBox(height: 16),
                    
                    // Chart
                    Container(
                      height: 300,
                      padding: const EdgeInsets.only(right: 20, left: 10, top: 40, bottom: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ]
                      ),
                      child: LineChart(
                        LineChartData(
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => theme.primaryColor.withValues(alpha: 0.95),
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((LineBarSpot touchedSpot) {
                                  return LineTooltipItem(
                                    '₹${touchedSpot.y.toStringAsFixed(2)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: horizontalInterval,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: isDark ? Colors.white10 : Colors.black12,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                                  return Text(labels[index], style: TextStyle(color: Colors.grey.shade500, fontSize: 12));
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: horizontalInterval,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text('₹${value.toInt()}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (spots.length - 1).toDouble() > 0 ? (spots.length - 1).toDouble() : 1,
                          minY: 0,
                          maxY: maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: theme.primaryColor,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                  strokeColor: theme.primaryColor,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    theme.primaryColor.withValues(alpha: 0.3),
                                    theme.primaryColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 100),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }
}
