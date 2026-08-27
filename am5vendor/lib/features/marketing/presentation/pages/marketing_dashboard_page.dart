import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/marketing_bloc.dart';
import '../bloc/marketing_event.dart';
import '../bloc/marketing_state.dart';

class MarketingDashboardPage extends StatelessWidget {
  const MarketingDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MarketingBloc>()..add(const FetchMarketingData(createdByMe: true)),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Marketing Dashboard'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Add Lead', icon: Icon(Icons.add_location_alt)),
                Tab(text: 'My Leads', icon: Icon(Icons.list_alt)),
                Tab(text: 'Collaterals', icon: Icon(Icons.picture_as_pdf)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _AddLeadView(),
              _MyLeadsView(),
              _CollateralsView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddLeadView extends StatefulWidget {
  const _AddLeadView();

  @override
  State<_AddLeadView> createState() => _AddLeadViewState();
}

class _AddLeadViewState extends State<_AddLeadView> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final leadData = {
        'shop_name': _shopNameController.text,
        'contact_person': _contactPersonController.text,
        'phone_number': _phoneController.text,
        'address': _addressController.text,
        // Location and image logic would be wired here
        'latitude': null,
        'longitude': null,
      };

      context.read<MarketingBloc>().add(CreateNewLead(leadData));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead Submitted Successfully!')),
      );

      _shopNameController.clear();
      _contactPersonController.clear();
      _phoneController.clear();
      _addressController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _shopNameController,
              decoration: const InputDecoration(labelText: 'Shop Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactPersonController,
              decoration: const InputDecoration(labelText: 'Contact Person', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            // Mock buttons for GPS and Camera
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text('Capture Location'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Picture'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Lead', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyLeadsView extends StatelessWidget {
  const _MyLeadsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketingBloc, MarketingState>(
      builder: (context, state) {
        if (state is MarketingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MarketingLoaded) {
          final leads = state.leads;
          if (leads.isEmpty) {
            return const Center(child: Text('No leads found. Start adding some!'));
          }
          return ListView.builder(
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(lead.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${lead.contactPerson} - ${lead.phoneNumber}\nStatus: ${lead.status}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          );
        } else if (state is MarketingError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Fetching leads...'));
      },
    );
  }
}

class _CollateralsView extends StatelessWidget {
  const _CollateralsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketingBloc, MarketingState>(
      builder: (context, state) {
        if (state is MarketingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MarketingLoaded) {
          final collaterals = state.collaterals;
          if (collaterals.isEmpty) {
            return const Center(child: Text('No promotional materials available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collaterals.length,
            itemBuilder: (context, index) {
              final item = collaterals[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.file_present, color: Colors.blue),
                  title: Text(item.title),
                  subtitle: Text(item.description ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      // Logic to open/download collateral
                    },
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
