// SmartChat - User Avatar Widget
//
// Reusable circular avatar that displays the user's photo
// or their initials as a fallback. Shows online status dot.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/utils.dart';

class UserAvatar extends StatelessWidget {
  /// The user's display name (used for initials fallback).
  final String name;

  /// URL to the user's profile photo (nullable).
  final String? photoURL;

  /// Radius of the avatar circle. Defaults to 24.
  final double radius;

  /// Whether to show the online status indicator.
  final bool showOnlineStatus;

  /// Whether the user is currently online.
  final bool isOnline;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoURL,
    this.radius = 24,
    this.showOnlineStatus = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Avatar circle
        CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: photoURL != null && photoURL!.isNotEmpty
              ? CachedNetworkImageProvider(photoURL!)
              : null,
          child: photoURL == null || photoURL!.isEmpty
              ? Text(
                  AppUtils.getInitials(name),
                  style: TextStyle(
                    fontSize: radius * 0.7,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                )
              : null,
        ),

        // Online indicator dot
        if (showOnlineStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
