import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:withme/core/di/di_setup_import.dart';
import 'package:withme/core/router/router_path.dart';
import 'package:withme/core/presentation/components/customer_item.dart';
import '../../../../../core/di/setup.dart';
import '../../../../core/presentation/core_presentation_import.dart';
import '../../../../domain/domain_import.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final viewModel = getIt<CustomerListViewModel>();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    viewModel.fetchOnce();


  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: viewModel.cachedCustomers,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
          }
          if (!snapshot.hasData || viewModel.state.isLoading == true) {
            return const MyCircularIndicator();
          }
          List<CustomerModel> originalCustomers = snapshot.data!;
          List<CustomerModel> customers =
              originalCustomers
                  .where((e) => e.name.contains(_searchText.trim()))
                  .toList();
          return Scaffold(
            appBar: _appBar(customers),
            body: _customerList(customers),
          );
        },
      ),
    );
  }

  SingleChildScrollView _customerList(List<CustomerModel> customers) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      if (context.mounted) {
                        context.push(
                          RoutePath.customer,
                          extra: customers[index],
                        );
                      }
                    },
                    child: CustomerItem(customer: customers[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(List<CustomerModel> customers) {
    return AppBar(
      title: Text('Customer ${customers.length}명'),
      actions: [
        AppBarSearchWidget(
          onSubmitted: (text) {
            setState(() => _searchText = text);
          },
        ),
      ],
    );
  }
}
