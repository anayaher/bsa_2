import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _TopBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _WelcomeText(),
              ),
              const SizedBox(height: 10),
              OrdersCardUI(),
              const SizedBox(height: 20),
              SubscriptionCardUI(),
              const SizedBox(height: 20),
              CustomerCardUI(),
              const SizedBox(height: 20),
              _DateSection(),
              const SizedBox(height: 15),
              _WeekSelector(),
              const SizedBox(height: 20),
              _TimelineCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleButton(Icons.menu),
          Row(
            children: [
              _circleButton(Icons.location_on_outlined),
              const SizedBox(width: 10),
              _circleButton(Icons.notifications_active_outlined),
              const SizedBox(width: 10),
              _circleButton(Icons.person),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
    ),
    child: Icon(icon),
  );
}

class _WelcomeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Welcome, Mypcot !!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "here is your dashboard....",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

class OrdersCardUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildDashboardCard(
      bgColor: const Color(0xFF2D9CDB),
      asset: "assets/orders.png",
      titleBoxColor: Colors.red,
      title: "You have 3 active orders from",
      subtitle: "02 Pending Orders",
      buttonText: "Orders",
      buttonColor: Colors.orange,
      avatars: ["assets/user1.png", "assets/user2.png", "assets/user3.png"],
    );
  }
}

class SubscriptionCardUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildDashboardCard(
      bgColor: const Color(0xFFDDBA12),
      asset: "assets/subscriptions.png",
      titleBoxColor: Colors.blue,
      title: "03 deliveries",
      subtitle: "119 Pending Deliveries",
      buttonText: "Subscriptions",
      buttonColor: Colors.blue,
      avatars: ["assets/user1.png", "assets/user2.png"],
    );
  }
}

class CustomerCardUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildDashboardCard(
      bgColor: const Color(0xFF27AE60),
      asset: "assets/customers.png",
      titleBoxColor: Colors.pink,
      title: "15 New customers",
      subtitle: "10 Active Customers",
      buttonText: "View Customers",
      buttonColor: Colors.pink,
      avatars: [
        "assets/user1.png",
        "assets/user2.png",
        "assets/user3.png",
        "assets/user4.png",
      ],
    );
  }
}

Widget buildDashboardCard({
  required Color bgColor,
  required String asset,
  required Color titleBoxColor,
  required String title,
  required String subtitle,
  required String buttonText,
  required Color buttonColor,
  List<String> avatars = const [],
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // LEFT Illustration
                  Image.asset(asset, height: 105),

                  const Spacer(),

                  // RIGHT Column (Badge + Subtitle Card)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Main badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: titleBoxColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // White subtitle box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // BUTTON
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Overlapping Avatar Row
        if (avatars.isNotEmpty)
          Positioned(
            right: 12,
            bottom: 85,
            child: Row(
              children: List.generate(avatars.length, (i) {
                return Transform.translate(
                  offset: Offset(-12.0 * i, 0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage(avatars[i]),
                  ),
                );
              }),
            ),
          ),
      ],
    ),
  );
}

Widget _badge(Color color, String text) => Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(text, style: const TextStyle(color: Colors.white)),
);

Widget _whiteBadge(String text) => Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(text),
);

// ================= DATE & TIMELINE =================
class _DateSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "January, 23 2021",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              _selectorBox("TIMELINE", Icons.arrow_drop_down),
              const SizedBox(width: 12),
              _selectorBox("JAN, 2021", Icons.calendar_month),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectorBox(String label, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Icon(icon)],
      ),
    ),
  );
}

class _WeekSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            [
                  "MON 20",
                  "TUE 21",
                  "WED 22",
                  "THU 23",
                  "FRI 24",
                  "SAT 25",
                  "SUN 26",
                ]
                .map(
                  (e) => Column(
                    children: [
                      Text(e),
                      if (e.contains("THU"))
                        const CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.teal,
                        ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "New order created",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "New Order created with Order",
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 10),
                Text("09:00 AM", style: TextStyle(color: Colors.orange)),
              ],
            ),
            const Spacer(),
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange,
              child: Icon(Icons.shopping_bag, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= NAVIGATION =================
Widget _buildFab() => FloatingActionButton(
  onPressed: () {},
  shape: const CircleBorder(),
  backgroundColor: Colors.blue,
  child: const Icon(Icons.add, size: 30),
);

Widget _buildBottomNav() => BottomAppBar(
  shape: const CircularNotchedRectangle(),
  child: SizedBox(
    height: 65,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _NavItem(icon: Icons.home, label: "Home"),
        _NavItem(icon: Icons.people, label: "Customers"),
        SizedBox(width: 50),
        _NavItem(icon: Icons.book, label: "Khata"),
        _NavItem(icon: Icons.shopping_bag, label: "Orders"),
      ],
    ),
  ),
);

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
