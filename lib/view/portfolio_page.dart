import 'package:cv_project/content/contact.dart';
import 'package:cv_project/content/experience.dart';
import 'package:cv_project/content/skills.dart';
import 'package:cv_project/data/personal_data.dart';
import 'package:cv_project/service/config_service.dart';
import 'package:cv_project/utils/web_utils.dart' as web;
import 'package:flutter/material.dart';

import '../content/about.dart';

class PortfolioPage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const PortfolioPage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  int _selectedIndex = 0;
  bool _isRussian = false;
  late Future<PersonalData> _personalData;
  PersonalData? _loadedData;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(4, (_) => GlobalKey());

  static const _navItemsEn = [
    (icon: Icons.person_outline, label: 'About'),
    (icon: Icons.code, label: 'Skills'),
    (icon: Icons.work_outline, label: 'Experience'),
    (icon: Icons.contact_mail_outlined, label: 'Contacts'),
  ];

  static const _navItemsRu = [
    (icon: Icons.person_outline, label: 'О себе'),
    (icon: Icons.code, label: 'Навыки'),
    (icon: Icons.work_outline, label: 'Опыт'),
    (icon: Icons.contact_mail_outlined, label: 'Контакты'),
  ];

  List<({IconData icon, String label})> get _navItems =>
      _isRussian ? _navItemsRu : _navItemsEn;

  @override
  void initState() {
    super.initState();
    _personalData = ConfigService.loadConfiguration(russian: _isRussian);
    _scrollController.addListener(_updateActiveSection);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateActiveSection)
      ..dispose();
    super.dispose();
  }

  void _updateActiveSection() {
    for (int i = _sectionKeys.length - 1; i >= 0; i--) {
      final ctx = _sectionKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy <= 300) {
        if (_selectedIndex != i) setState(() => _selectedIndex = i);
        return;
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    final ctx = _sectionKeys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isRussian = !_isRussian;
      _loadedData = null;
      _personalData = ConfigService.loadConfiguration(russian: _isRussian);
    });
  }

  void _printResume() {
    if (_loadedData == null) return;
    web.printResumeHtml(_buildPrintHtml(_loadedData!));
  }

  bool get _isDark => widget.themeMode == ThemeMode.dark;
  IconData get _themeIcon => _isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined;
  String get _themeTooltip => _isDark ? 'Switch to light mode' : 'Switch to dark mode';
  String get _themeLabel => _isDark ? 'Light' : 'Dark';

  String get _langLabel => _isRussian ? 'ENG' : 'РУС';
  String get _langTooltip => _isRussian ? 'Switch to English' : 'Переключить на русский';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return FutureBuilder<PersonalData>(
      future: _personalData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            _loadedData ??= snapshot.data;
            return Scaffold(
              appBar: isMobile
                  ? AppBar(
                      title: const Text('Resume'),
                      centerTitle: true,
                      actions: [
                        Tooltip(
                          message: _langTooltip,
                          child: TextButton(
                            onPressed: _toggleLanguage,
                            child: Text(_langLabel),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_themeIcon),
                          tooltip: _themeTooltip,
                          onPressed: widget.onToggleTheme,
                        ),
                        if (!web.isSafari)
                          IconButton(
                            icon: const Icon(Icons.print_outlined),
                            tooltip: 'Print / Save as PDF',
                            onPressed: _printResume,
                          ),
                      ],
                    )
                  : null,
              drawer: isMobile ? _buildMobileDrawer() : null,
              body: _buildBody(snapshot.data!, isMobile),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Loading error: ${snapshot.error}'));
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildBody(PersonalData data, bool isMobile) {
    return Row(
      children: [
        if (!isMobile) _buildDesktopNavigation(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      KeyedSubtree(
                        key: _sectionKeys[0],
                        child: _FadeInSection(
                          child: AboutSection(data: data),
                        ),
                      ),
                      KeyedSubtree(
                        key: _sectionKeys[1],
                        child: _FadeInSection(
                          delay: const Duration(milliseconds: 150),
                          child: SkillsSection(data: data),
                        ),
                      ),
                      KeyedSubtree(
                        key: _sectionKeys[2],
                        child: _FadeInSection(
                          delay: const Duration(milliseconds: 300),
                          child: ExperienceSection(data: data),
                        ),
                      ),
                      KeyedSubtree(
                        key: _sectionKeys[3],
                        child: _FadeInSection(
                          delay: const Duration(milliseconds: 450),
                          child: ContactsSection(data: data),
                        ),
                      ),
                      _buildFooter(context, data),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNavigation() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.language),
                  tooltip: _langTooltip,
                  onPressed: _toggleLanguage,
                ),
                const SizedBox(height: 4),
                Text(_langLabel, style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 12),
                IconButton.filledTonal(
                  icon: Icon(_themeIcon),
                  tooltip: _themeTooltip,
                  onPressed: widget.onToggleTheme,
                ),
                const SizedBox(height: 4),
                Text(_themeLabel, style: const TextStyle(fontSize: 11)),
                if (!web.isSafari) ...[
                  const SizedBox(height: 12),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.print_outlined),
                    tooltip: 'Print / Save as PDF',
                    onPressed: _printResume,
                  ),
                  const SizedBox(height: 4),
                  const Text('Print', style: TextStyle(fontSize: 11)),
                ],
              ],
            ),
          ),
        ),
      ),
      destinations: _navItems
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                label: Text(item.label),
              ))
          .toList(),
    );
  }

  Widget _buildMobileDrawer() {
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            child: Text(
              'Navigation',
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (int i = 0; i < _navItems.length; i++)
            ListTile(
              leading: Icon(_navItems[i].icon),
              title: Text(_navItems[i].label),
              selected: _selectedIndex == i,
              selectedColor: scheme.primary,
              onTap: () {
                _onItemTapped(i);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, PersonalData data) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Divider(color: scheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} Gleb Abakshin — Java Software Engineer',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: ${data.lastUpdated}',
            style: TextStyle(color: scheme.outline, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Print HTML generator ───────────────────────────────────────────────────

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _buildPrintHtml(PersonalData data) {
  final info = data.mainInfo;
  final sb = StringBuffer();

  sb.write('''<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8">
<style>
  * { box-sizing: border-box; }
  body { font-family: Arial, sans-serif; font-size: 11pt; color: #111; margin: 0; padding: 24px 32px; }
  h1 { font-size: 20pt; margin: 0 0 4px; }
  h2 { font-size: 13pt; border-bottom: 1.5px solid #ccc; padding-bottom: 4px; margin: 20px 0 10px; text-transform: uppercase; letter-spacing: .04em; }
  h3 { font-size: 11pt; margin: 10px 0 2px; }
  .header { display: flex; gap: 20px; align-items: flex-start; margin-bottom: 16px; }
  .header img { width: 90px; height: 90px; border-radius: 8px; object-fit: cover; flex-shrink: 0; }
  .position { color: #1565C0; font-size: 13pt; font-weight: 600; margin: 4px 0; }
  .meta { color: #555; font-size: 9.5pt; margin: 2px 0; }
  .about { font-size: 10.5pt; line-height: 1.55; white-space: pre-line; }
  .skills { display: flex; flex-wrap: wrap; gap: 5px; }
  .skill { background: #E3F2FD; color: #0D47A1; padding: 2px 10px; border-radius: 10px; font-size: 9.5pt; }
  .job { margin-bottom: 14px; page-break-inside: avoid; }
  .job-header { display: flex; justify-content: space-between; align-items: baseline; }
  .company { font-size: 12pt; font-weight: bold; }
  .job-position { font-size: 10pt; color: #444; margin: 1px 0 6px; }
  .period { color: #777; font-size: 9.5pt; }
  .project { margin: 6px 0 6px 12px; }
  .project-title { font-weight: bold; font-size: 10.5pt; }
  .project-desc { font-size: 9.5pt; color: #444; margin: 2px 0; }
  .project-skills { font-size: 9pt; color: #666; margin: 2px 0; }
  ul { margin: 4px 0 0; padding-left: 18px; }
  li { font-size: 9.5pt; margin: 1px 0; }
  .contacts { display: flex; flex-wrap: wrap; gap: 8px 24px; }
  .contact { font-size: 10pt; }
  a { color: #1565C0; text-decoration: none; }
</style>
</head><body>
''');

  // ── Header ─────────────────────────────────────────────────
  sb.write('<div class="header">');
  final photo = info.photoFallbackLink ?? info.photoLink;
  if (photo.isNotEmpty) {
    sb.write('<img src="${_esc(photo)}" onerror="this.style.display=\'none\'">');
  }
  sb.write('<div>');
  sb.write('<h1>${_esc(info.lastName)} ${_esc(info.firstName)}</h1>');
  sb.write('<div class="position">${_esc(info.position)}</div>');
  sb.write('<div class="meta">Born: ${_esc(info.birthDate)}</div>');
  sb.write('<div class="meta">${_esc(info.currentLocation)}</div>');
  sb.write('<div class="meta">${_esc(info.education)}</div>');
  sb.write('<div class="meta">${_esc(info.addition)}</div>');
  sb.write('</div></div>');

  // ── About ──────────────────────────────────────────────────
  sb.write('<h2>About</h2>');
  sb.write('<div class="about">${_esc(data.personalData)}</div>');

  // ── Skills ─────────────────────────────────────────────────
  sb.write('<h2>Skills</h2><div class="skills">');
  for (final s in data.skills) {
    sb.write('<span class="skill">${_esc(s)}</span>');
  }
  sb.write('</div>');

  // ── Experience ─────────────────────────────────────────────
  sb.write('<h2>Experience</h2>');
  for (final exp in data.workExperience) {
    sb.write('<div class="job">');
    sb.write('<div class="job-header">');
    sb.write('<span class="company">${_esc(exp.company)}</span>');
    sb.write('<span class="period">${_esc(exp.period)}</span>');
    sb.write('</div>');
    sb.write('<div class="job-position">${_esc(exp.position)}</div>');
    for (final proj in exp.projects) {
      sb.write('<div class="project">');
      sb.write('<div class="project-title">${_esc(proj.name)} '
          '<span class="period">${_esc(proj.period)}</span></div>');
      sb.write('<div class="project-desc">${_esc(proj.description)}</div>');
      sb.write('<div class="project-skills">Skills: ${proj.skills.map(_esc).join(', ')}</div>');
      sb.write('<ul>');
      for (final r in proj.responsibilities) {
        sb.write('<li>${_esc(r)}</li>');
      }
      sb.write('</ul></div>');
    }
    sb.write('</div>');
  }

  // ── Contacts ───────────────────────────────────────────────
  final links = data.socialLinks;
  sb.write('<h2>Contacts</h2><div class="contacts">');
  sb.write('<div class="contact">Email: <a href="mailto:${_esc(links.email)}">${_esc(links.email)}</a></div>');
  sb.write('<div class="contact">LinkedIn: <a href="https://${_esc(links.linkedIn)}">${_esc(links.linkedIn)}</a></div>');
  sb.write('<div class="contact">GitHub: <a href="https://${_esc(links.github)}">${_esc(links.github)}</a></div>');
  sb.write('<div class="contact">Habr Career: <a href="https://${_esc(links.habrCareer)}">${_esc(links.habrCareer)}</a></div>');
  sb.write('</div>');

  sb.write('</body></html>');
  return sb.toString();
}

// ─── Staggered fade-in + slide-up animation wrapper ────────────────────────

class _FadeInSection extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeInSection({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_FadeInSection> createState() => _FadeInSectionState();
}

class _FadeInSectionState extends State<_FadeInSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}