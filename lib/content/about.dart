import 'package:flutter/material.dart';
import '../data/personal_data.dart';

class _PhotoWithFallback extends StatefulWidget {
  final String url;
  final String? fallbackUrl;

  const _PhotoWithFallback({required this.url, this.fallbackUrl});

  @override
  State<_PhotoWithFallback> createState() => _PhotoWithFallbackState();
}

class _PhotoWithFallbackState extends State<_PhotoWithFallback> {
  bool _useFallback = false;

  @override
  Widget build(BuildContext context) {
    final src = _useFallback ? widget.fallbackUrl! : widget.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        src,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: 200,
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (!_useFallback && widget.fallbackUrl != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _useFallback = true);
            });
            return const SizedBox(width: 200, height: 200);
          }
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.person,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  final PersonalData data;

  const AboutSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              final photo = _buildPhoto(data.mainInfo.photoLink, data.mainInfo.photoFallbackLink);
              final info = _buildInfo(context, scheme);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    photo,
                    const SizedBox(width: 24),
                    Expanded(child: info),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: photo),
                    const SizedBox(height: 20),
                    info,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto(String url, String? fallbackUrl) {
    return _PhotoWithFallback(url: url, fallbackUrl: fallbackUrl);
  }

  Widget _buildInfo(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${data.mainInfo.lastName} ${data.mainInfo.firstName}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          data.mainInfo.position,
          style: TextStyle(
            fontSize: 18,
            color: scheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data.personalData,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              context,
              Icons.cake_outlined,
              'Born: ${data.mainInfo.birthDate}',
            ),
            _buildChip(
              context,
              Icons.location_on_outlined,
              data.mainInfo.currentLocation,
            ),
            _buildChip(
              context,
              Icons.school_outlined,
              data.mainInfo.education,
            ),
            _buildChip(
              context,
              Icons.open_in_new,
              data.mainInfo.addition,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 16, color: scheme.onPrimaryContainer),
      label: Text(text, style: TextStyle(color: scheme.onPrimaryContainer)),
      backgroundColor: scheme.primaryContainer,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}