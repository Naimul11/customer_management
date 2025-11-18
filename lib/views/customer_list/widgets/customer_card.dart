import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/customer_model.dart';
import '../../../core/constants/api_constants.dart';

/// Widget to display a customer card
class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback? onTap;

  const CustomerCard({
    Key? key,
    required this.customer,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = customer.getImageUrl(ApiConstants.imageBaseUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Circular Customer Image on left
                Hero(
                  tag: 'customer_${customer.id}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: ClipOval(
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Customer Details on right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        customer.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Code
                      if (customer.code != null)
                        Text(
                          customer.code!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 4),

                      // Email & Phone
                      if (customer.email != null && customer.email!.isNotEmpty && customer.phone != null && customer.phone!.isNotEmpty) ...[
                        Text(
                          customer.email!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Phone ${customer.phone!}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else if (customer.email != null && customer.email!.isNotEmpty) ...[
                        Text(
                          customer.email!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                        Text(
                          'Phone ${customer.phone!}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else if (customer.address != null && customer.address!.isNotEmpty) ...[
                        Text(
                          customer.address!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),

                      // Balance
                      Text(
                        'Balance: \$${customer.balance?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: (customer.balance ?? 0) >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
