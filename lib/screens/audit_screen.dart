// parte linsaith
// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/roles_provider.dart';
import '../providers/users_provider.dart';
import '../providers/reservations_provider.dart';
import '../providers/payments_provider.dart';
import '../providers/suppliers_provider.dart';
import '../providers/purchases_provider.dart';

class AuditScreen extends StatefulWidget {
  static const routeName = '/audit';
  @override
  _AuditScreenState createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildEntry(Map<String, dynamic> e){
    final action = e['action'] ?? '';
    final actor = e['actor'] is Map ? (e['actor']['name'] ?? e['actor']['id'] ?? '') : e['actor'].toString();
    final ts = e['timestamp'] ?? '';
    return Card(child: ListTile(
      title: Text(action),
      subtitle: Text('Actor: $actor\n${_prettyDetails(e)}'),
      isThreeLine: true,
      trailing: Text(ts.toString().split('T').first),
    ));
  }

  String _prettyDetails(Map<String,dynamic> e){
    final copy = Map<String,dynamic>.from(e);
    copy.remove('action'); copy.remove('actor'); copy.remove('timestamp');
    if (copy.isEmpty) return '';
    return copy.entries.map((kv) => '${kv.key}: ${kv.value}').join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final rolesProv = Provider.of<RolesProvider>(context);
    final usersProv = Provider.of<UsersProvider>(context);
    final reservationsProv = Provider.of<ReservationsProvider>(context);
    final paymentsProv = Provider.of<PaymentsProvider>(context);
    final suppliersProv = Provider.of<SuppliersProvider>(context);
    final purchasesProv = Provider.of<PurchasesProvider>(context);
    final rolesAudit = rolesProv.audit;
    final usersAudit = usersProv.audit;
    final reservationsAudit = reservationsProv.audit;
    final paymentsAudit = paymentsProv.audit;
    final suppliersAudit = suppliersProv.audit;
    final purchasesAudit = purchasesProv.audit;
    return Scaffold(
      appBar: AppBar(title: Text('Auditoría'), bottom: TabBar(controller: _tabController, tabs: [Tab(text: 'Roles'), Tab(text: 'Usuarios'), Tab(text: 'Reservas'), Tab(text: 'Pagos'), Tab(text: 'Proveedores'), Tab(text: 'Compras')])),
      body: TabBarView(controller: _tabController, children: [
        rolesAudit.isEmpty ? Center(child: Text('No hay registros de auditoría para roles')) : ListView.separated(padding: EdgeInsets.all(12), itemCount: rolesAudit.length, separatorBuilder: (_,__)=>SizedBox(height:8), itemBuilder: (ctx,i)=> _buildEntry(rolesAudit[i])),
        usersAudit.isEmpty ? Center(child: Text('No hay registros de auditoría para usuarios')) : ListView.separated(padding: EdgeInsets.all(12), itemCount: usersAudit.length, separatorBuilder: (_,__)=>SizedBox(height:8), itemBuilder: (ctx,i)=> _buildEntry(usersAudit[i])),
        reservationsAudit.isEmpty ? Center(child: Text('No hay registros de auditoría para reservas')) : ListView.separated(padding: EdgeInsets.all(12), itemCount: reservationsAudit.length, separatorBuilder: (_,__)=>SizedBox(height:8), itemBuilder: (ctx,i)=> _buildEntry(reservationsAudit[i])),
        paymentsAudit.isEmpty ? Center(child: Text('No hay registros de auditoría para pagos')) : ListView.separated(padding: EdgeInsets.all(12), itemCount: paymentsAudit.length, separatorBuilder: (_,__)=>SizedBox(height:8), itemBuilder: (ctx,i)=> _buildEntry(paymentsAudit[i])),
        suppliersAudit.isEmpty ? Center(child: Text('No hay registros de auditoría para proveedores')) : ListView.separated(padding: EdgeInsets.all(12), itemCount: suppliersAudit.length, separatorBuilder: (_,__)=>SizedBox(height:8), itemBuilder: (ctx,i)=> _buildEntry(suppliersAudit[i])),
        purchasesAudit.isEmpty ? Center(child: Text('No hay registros de auditoría para compras')) : ListView.separated(padding: EdgeInsets.all(12), itemCount: purchasesAudit.length, separatorBuilder: (_,__)=>SizedBox(height:8), itemBuilder: (ctx,i)=> _buildEntry(purchasesAudit[i])),
      ]),
    );
  }
}
