class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, "Meal Count", Icons.fastfood,
              "/mealCount"),

          _tile(context, "Analytics", Icons.bar_chart,
              "/analytics"),

          _tile(context, "Rooms", Icons.meeting_room,
              "/rooms"),

          _tile(context, "Tenants", Icons.people,
              "/tenants"),

          _tile(context, "Complaints", Icons.report,
              "/complaints"),
        ],
      ),
    );
  }

  Widget _tile(
      BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}