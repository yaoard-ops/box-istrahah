import 'package:flutter/material.dart';

void main() {
  runApp(const IstirahahApp());
}

class IstirahahApp extends StatelessWidget {
  const IstirahahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // اسم الشهر الحالي
  String currentMonth = 'شهر 1';

  // الفائض من الشهر الماضي
  double carriedOverSurplus = 0.0;

  // مبلغ القطة الأساسي لهذا الشهر
  double globalMonthlyQuota = 0.0;

  // قوائم البيانات
  List variableExpenses = [];
  List members = [];

  // قائمة الأرشيف لحفظ الأشهر السابقة
  List archivedMonths = [];

  // تبديل حالة سداد العضو
  void _toggleMemberStatus(int index) {
    setState(() {
      var member = members[index] as Map;
      bool currentStatus = member['status'] as bool;
      member['status'] = !currentStatus;
      double memberQuota = (member['quota'] as num).toDouble();
      member['paid'] = !currentStatus ? memberQuota : 0.0;
    });
  }

  // تغيير اسم الشهر الحالي
  void _editCurrentMonth() {
    final controller = TextEditingController(text: currentMonth);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تحديد الشهر الحالي'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اسم الشهر (مثال: شهر 2)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  currentMonth = controller.text;
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // تعديل مبلغ القطة العام
  void _editGlobalQuota() {
    final controller = TextEditingController(
      text: globalMonthlyQuota.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل مبلغ القطة العام'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'مبلغ القطة الافتراضي (ريال)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  globalMonthlyQuota =
                      double.tryParse(controller.text) ?? globalMonthlyQuota;
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // تعديل الفائض من الشهر الماضي
  void _editCarriedOverSurplus() {
    final controller = TextEditingController(
      text: carriedOverSurplus.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل الفائض من الشهر الماضي'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'المبلغ (ريال)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  carriedOverSurplus =
                      double.tryParse(controller.text) ?? carriedOverSurplus;
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // الانتقال للشهر التالي وترحيل الفائض وأرشفة الشهر الحالي تلقائياً
  void _moveToNextMonth(
    double totalIncome,
    double totalExpenses,
    double finalTotalSurplus,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔄 أرشفة والانتقال للشهر التالي'),
        content: Text(
          'هل تريد حفظ تقرير "$currentMonth" في الأرشيف، وترحيل الفائض النهائي ($finalTotalSurplus ريال) إلى الشهر الجديد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              // 1. حفظ الشهر الحالي في قائمة الأرشيف قبل ترحيله
              archivedMonths.add({
                'monthName': currentMonth,
                'carriedOver': carriedOverSurplus,
                'income': totalIncome,
                'expenses': totalExpenses,
                'surplus': finalTotalSurplus,
                'membersCount': members.length,
                'paidCount': members
                    .where((m) => (m as Map)['status'] == true)
                    .length,
              });

              setState(() {
                carriedOverSurplus =
                    finalTotalSurplus; // ترحيل الفائض للشهر الجديد
                // تصفير سداد الأعضاء مع إبقاء أسمائهم ومبالغهم ثابتة
                for (var m in members) {
                  var member = m as Map;
                  member['status'] = false;
                  member['paid'] = 0.0;
                }
                variableExpenses.clear(); // مسح مصروفات الشهر القديم
                currentMonth =
                    'شهر ${archivedMonths.length + 1}'; // تحديث اسم الشهر تلقائياً
              });

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم أرشفة الشهر بنجاح وبدء الشهر الجديد!'),
                ),
              );
            },
            child: const Text('تأكيد الأرشفة والترحيل'),
          ),
        ],
      ),
    );
  }

  // نافذة استعراض الأرشيف للأشهر الماضية
  void _showArchiveDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📁 أرشيف الأشهر السابقة'),
        content: SizedBox(
          width: 350,
          child: archivedMonths.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'لا يوجد أشهر مؤرشفة حتى الآن.\nقم بترحيل الشهر الحالي ليظهر هنا.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: archivedMonths.length,
                  itemBuilder: (context, index) {
                    var arch = archivedMonths[index] as Map;
                    return Card(
                      color: Colors.grey.shade100,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📅 ${arch['monthName']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.teal,
                              ),
                            ),
                            const Divider(),
                            Text(
                              '• الفائض السابق: ${arch['carriedOver']} ريال',
                            ),
                            Text(
                              '• المقبوضات: ${arch['income']} ريال (${arch['paidCount']}/${arch['membersCount']} أفراد)',
                            ),
                            Text('• المصروفات: ${arch['expenses']} ريال'),
                            Text(
                              '• الفائض النهائي: ${arch['surplus']} ريال',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // تعديل قطة عضو محدد
  void _editMemberQuota(int index) {
    var member = members[index] as Map;
    final controller = TextEditingController(text: member['quota'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل قطة الفرد: ${member['name']}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'مبلغ القطة الخاص (ريال)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  double newQuota =
                      double.tryParse(controller.text) ??
                      (member['quota'] as num).toDouble();
                  member['quota'] = newQuota;
                  if (member['status'] as bool) {
                    member['paid'] = newQuota;
                  }
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // حذف عضو
  void _removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
  }

  // إضافة عضو جديد (ثابت للشهور القادمة)
  void _showAddMemberDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة عضو جديد (ثابت للشهور القادمة)'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'اسم العضو (سيُسجل بقطة: $globalMonthlyQuota ريال)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  members.add({
                    'name': nameController.text,
                    'quota': globalMonthlyQuota,
                    'paid': 0.0,
                    'status': false,
                  });
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // إضافة مصروف جديد
  void _showAddVariableExpenseDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مصروف جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المصروف'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ (ريال)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                setState(() {
                  variableExpenses.add({
                    'name': nameController.text,
                    'amount': double.tryParse(amountController.text) ?? 0.0,
                  });
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // تقرير الخلاصة الشامل
  String _generateReportText(
    double totalIncome,
    double totalExpenses,
    double finalTotalSurplus,
  ) {
    int totalMembersCount = members.length;
    int paidMembersCount = members
        .where((m) => (m as Map)['status'] == true)
        .length;

    String report = '📄 تقرير صندوق الاستراحة - $currentMonth\n';
    report += '-----------------------------------\n';
    report += '👥 تفاصيل الأعضاء والسداد:\n';
    if (members.isEmpty) {
      report += 'لا يوجد أعضاء مسجلين.\n';
    } else {
      for (var m in members) {
        var member = m as Map;
        bool paid = member['status'] as bool;
        double paidAmt = (member['paid'] as num).toDouble();
        report +=
            '• ${member['name']}: ${paid ? 'سدد ($paidAmt ريال)' : 'لم يسدد'}\n';
      }
    }
    report += '-----------------------------------\n';
    report += '📥 الفائض من الشهر الماضي: $carriedOverSurplus ريال\n';
    report +=
        '💰 إجمالي المقبوضات: $totalIncome ريال ($paidMembersCount من أصل $totalMembersCount أفراد)\n';
    report += '🛒 إجمالي المصروفات: $totalExpenses ريال\n';
    report += '-----------------------------------\n';
    report += '📈 الفائض لهذا الشهر: $finalTotalSurplus ريال\n';
    return report;
  }

  // نافذة الخلاصة والطباعة
  void _showMonthlySummaryDialog(
    double totalIncome,
    double totalExpenses,
    double finalTotalSurplus,
  ) {
    String reportText = _generateReportText(
      totalIncome,
      totalExpenses,
      finalTotalSurplus,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('📄 تقرير خلاصة: $currentMonth'),
        content: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Text(
              reportText,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.print, size: 18),
            label: const Text('طباعة التقرير'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🖨️ تم طباعة تقرير "$currentMonth" بكافة التفاصيل بنجاح!',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalExpenses = variableExpenses.fold(
      0.0,
      (s, e) => s + ((e as Map)['amount'] as num).toDouble(),
    );
    double totalIncome = members.fold(
      0.0,
      (s, m) => s + ((m as Map)['paid'] as num).toDouble(),
    );
    double currentMonthSurplus = totalIncome - totalExpenses;
    double finalTotalSurplus = carriedOverSurplus + currentMonthSurplus;

    int totalMembersCount = members.length;
    int paidMembersCount = members
        .where((m) => (m as Map)['status'] == true)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text('صندوق قطة الاستراحة - $currentMonth'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_special, color: Colors.amberAccent),
            tooltip: 'عرض أرشيف الأشهر السابقة',
            onPressed: _showArchiveDialog,
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'إضافة عضو',
            onPressed: _showAddMemberDialog,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'الخلاصة والطباعة',
            onPressed: () => _showMonthlySummaryDialog(
              totalIncome,
              totalExpenses,
              finalTotalSurplus,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVariableExpenseDialog,
        backgroundColor: Colors.teal,
        tooltip: 'إضافة مصروف',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.teal.shade100,
            child: ListTile(
              title: Text(
                '📅 الشهر الحالي: $currentMonth',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                'انقر لأرشفة الشهر وترحيل الفائض للشهر التالي',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.teal),
                    tooltip: 'تغيير اسم الشهر',
                    onPressed: _editCurrentMonth,
                  ),
                  IconButton(
                    icon: const Icon(Icons.update, color: Colors.indigo),
                    tooltip: 'أرشفة والانتقال للشهر التالي وترحيل الفائض',
                    onPressed: () => _moveToNextMonth(
                      totalIncome,
                      totalExpenses,
                      finalTotalSurplus,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.amber.shade50,
            child: ListTile(
              title: const Text('💰 مبلغ القطة العام (للأعضاء الجدد)'),
              subtitle: Text('$globalMonthlyQuota ريال'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.teal),
                tooltip: 'تعديل القطة العامة',
                onPressed: _editGlobalQuota,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'إجمالي الفائض المتبقي للشهر الحالي',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${finalTotalSurplus.toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: finalTotalSurplus >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'المقبوضات: ${totalIncome.toStringAsFixed(0)} ($paidMembersCount/$totalMembersCount أفراد)',
                      ),
                      Text('المصروفات: ${totalExpenses.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            color: Colors.grey.shade100,
            child: ListTile(
              title: const Text('📥 الفائض من الشهر الماضي'),
              subtitle: Text('$carriedOverSurplus ريال'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.teal),
                onPressed: _editCarriedOverSurplus,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '👥 أعضاء القطة (العدد الإجمالي: $totalMembersCount أفراد - ثابتة للشهور القادمة)',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'لا يوجد أعضاء مضافون حالياً. اضغط على أيقونة إضافة عضو في الأعلى (+👤).',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...members.asMap().entries.map((entry) {
            int idx = entry.key;
            var member = entry.value as Map;
            bool isPaid = member['status'] as bool;
            double quota = (member['quota'] as num).toDouble();
            return Card(
              child: ListTile(
                onTap: () => _toggleMemberStatus(idx),
                title: Text(
                  member['name'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isPaid
                      ? 'سدد القطة: $quota ريال'
                      : 'لم يسدد بعد (القطة المطلوبة: $quota ريال)',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.teal,
                      ),
                      tooltip: 'تعديل قطة هذا الفرد',
                      onPressed: () => _editMemberQuota(idx),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      tooltip: 'حذف العضو',
                      onPressed: () => _removeMember(idx),
                    ),
                    Icon(
                      isPaid ? Icons.check_circle : Icons.error_outline,
                      color: isPaid ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            '🛒 المصروفات (اسحب للحذف)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (variableExpenses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'لا توجد مصروفات مسجلة.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...variableExpenses.asMap().entries.map((entry) {
            int idx = entry.key;
            var expense = entry.value as Map;
            return Dismissible(
              key: Key(expense['name'].toString() + idx.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                setState(() {
                  variableExpenses.removeAt(idx);
                });
              },
              child: Card(
                child: ListTile(
                  title: Text(expense['name'].toString()),
                  trailing: Text(
                    '${expense['amount']} ريال',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
