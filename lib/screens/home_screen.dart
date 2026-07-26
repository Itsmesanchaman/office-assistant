import 'package:flutter/material.dart';
import 'package:tmobile_app/screens/dashboard/action_card.dart';
import 'package:tmobile_app/screens/dashboard/employee_details.dart';
import '../services/employee_service.dart';
import './constants/app_colors.dart';
import 'dashboard/task_history_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String searchQuery = "";
  bool isSearching = false;

  void openTask(BuildContext context, String taskName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskHistoryScreen(taskTitle: taskName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EmployeeService.instance,
      builder: (context, _) {
        final employees = EmployeeService.instance.employees;

        final suggestions = employees.where((employee) {
          return employee.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
        }).toList();

        final displayedEmployees = searchQuery.isEmpty
            ? employees
            : suggestions;

        return Scaffold(
          backgroundColor: const Color(0xffF5F5F5),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              isSearching = value.trim().isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'search_employee...'.tr(),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        searchController.clear();
                                        searchQuery = "";
                                        isSearching = false;
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),

                        /// SEARCH SUGGESTIONS
                        if (isSearching)
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: suggestions.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: Text(
                                        "No employee found",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: suggestions.length,
                                    itemBuilder: (context, index) {
                                      final employee = suggestions[index];
                                      return ListTile(
                                        leading: const Icon(
                                          Icons.search,
                                          color: Colors.grey,
                                        ),
                                        title: Text(employee.name),
                                        subtitle: Text(employee.designation),
                                        trailing: const Icon(
                                          Icons.north_west,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            searchController.text =
                                                employee.name;
                                            searchQuery = employee.name;
                                            isSearching = false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                          ),
                      ],
                    ),
                  ),

                  /// HIDE EVERYTHING WHILE SEARCHING
                  if (!isSearching) ...[
                    /// QUICK ACTIONS -> jump straight to that task type's live report
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          QuickActionCard(
                            icon: Image.asset(
                              'assets/images/folder.png',
                              width: 40,
                              height: 40,
                            ),
                            title: 'bring_file'.tr(),
                            onTap: () => openTask(context, "Bring File"),
                          ),
                          QuickActionCard(
                            icon: Image.asset(
                              'assets/images/tea.png',
                              width: 50,
                              height: 40,
                            ),
                            title: 'prepare_tea'.tr(),
                            onTap: () => openTask(context, "Prepare Tea"),
                          ),
                          QuickActionCard(
                            icon: Image.asset(
                              'assets/images/meetingg.png',
                              width: 60,
                              height: 55,
                            ),
                            title: 'urgent_meeting'.tr(),
                            onTap: () => openTask(context, "Urgent Meeting"),
                          ),
                          QuickActionCard(
                            icon: Image.asset(
                              'assets/images/manrun.png',
                              width: 45,
                              height: 40,
                            ),
                            title: 'come_now'.tr(),
                            onTap: () => openTask(context, "Come Now"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// EMPLOYEE LIST — tap the bell on any card to assign a task
                    displayedEmployees.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(30),
                            child: Text(
                              "No employee found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedEmployees.length,
                            itemBuilder: (context, index) {
                              final employee = displayedEmployees[index];
                              return EmployeeCard(employee: employee);
                            },
                          ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
