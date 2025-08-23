import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/sex_widget.dart';
import '../../../domain/model/customer_model.dart';
import '../../utils/is_birthday_within_7days.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/sex_widget.dart';
import '../../../domain/model/customer_model.dart';
import '../../utils/is_birthday_within_7days.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/sex_widget.dart';
import '../../../domain/model/customer_model.dart';
import '../../utils/is_birthday_within_7days.dart';
import 'package:flutter/material.dart';
import 'package:withme/core/presentation/components/sex_widget.dart';
import '../../../domain/model/customer_model.dart';

class ProspectItemIcon extends StatelessWidget {
  final CustomerModel customer;
  final double size;

  const ProspectItemIcon({
    super.key,
    required this.customer,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color iconColor = getSexIconColor(customer.sex, colorScheme);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        customer.name.isNotEmpty ? customer.name[0] : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.5,
        ),
      ),
    );
  }
}
