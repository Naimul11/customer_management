import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/customer_model.dart';
import '../../../core/constants/api_constants.dart';

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
    final theme = Theme.of(context);
    final imageUrl = customer.getImageUrl(ApiConstants.imageBaseUrl);
    final balance = customer.balance ?? 0;
    final isPositiveBalance = balance >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: theme.primaryColor.withOpacity(0.1),
          highlightColor: theme.primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildModernAvatar(imageUrl, theme),
                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name?.trim().isNotEmpty == true
                            ? customer.name!
                            : 'Unknown Customer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      if (customer.code != null && customer.code!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              customer.code!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),

                      ..._buildContactInfo(),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPositiveBalance
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPositiveBalance
                                ? const Color(0xFF10B981).withOpacity(0.3)
                                : const Color(0xFFEF4444).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Balance: \$${balance.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isPositiveBalance
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAvatar(String? imageUrl, ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.7),
                Colors.grey.shade300,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildShimmerAvatar(),
                        errorWidget: (context, url, error) => _buildFallbackAvatar(theme),
                      )
                    : _buildFallbackAvatar(theme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerAvatar() {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          padding: const EdgeInsets.all(2),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.grey[600]!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(ThemeData theme) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.2),
          ],
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: 32,
        color: theme.primaryColor.withOpacity(0.7),
      ),
    );
  }

  List<Widget> _buildContactInfo() {
    final widgets = <Widget>[];
    final hasEmail = customer.email != null && customer.email!.isNotEmpty;
    final hasPhone = customer.phone != null && customer.phone!.isNotEmpty;
    final hasAddress = customer.address != null && customer.address!.isNotEmpty;

    if (hasEmail) {
      widgets.addAll([
        _buildContactRow(
          Icons.email_outlined,
          customer.email!,
        ),
        const SizedBox(height: 4),
      ]);
    }

    if (hasPhone) {
      widgets.addAll([
        _buildContactRow(
          Icons.phone_outlined,
          customer.phone!,
        ),
        const SizedBox(height: 4),
      ]);
    }

    if (hasAddress && !hasEmail && !hasPhone) {
      widgets.addAll([
        _buildContactRow(
          Icons.location_on_outlined,
          customer.address!,
        ),
        const SizedBox(height: 4),
      ]);
    }

    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }

    return widgets;
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}