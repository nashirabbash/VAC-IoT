import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/asset/color.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/splitButton.dart';
import 'package:vac_dashboard_app/component/menu.dart';
import 'package:vac_dashboard_app/component/alert_dialog.dart';
import 'package:vac_dashboard_app/component/stepper.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/screens/welcomeScreens.dart';

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'VAC Dashboard',
          themeMode: mode,
          theme: ThemeData(
            colorScheme: AppColors.colorScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background Color
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.black, // Dark background
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF007AFF),
              brightness: Brightness.dark,
            ),
          ),
          home: const WelcomeScreens(),
        );
      },
    );
  }
}

class ComponentSandboxPage extends StatefulWidget {
  const ComponentSandboxPage({super.key});

  @override
  State<ComponentSandboxPage> createState() => _ComponentSandboxPageState();
}

class _ComponentSandboxPageState extends State<ComponentSandboxPage> {
  int _stepperVal1 = 5;
  int _stepperVal2 = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Component Sandbox'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Typography'),
              Tab(text: 'Buttons & Split'),
              Tab(text: 'Steppers & Headers'),
              Tab(text: 'Lists & Dialogs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTypographyTab(),
            _buildButtonsTab(),
            _buildSteppersTab(),
            _buildListsTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: TYPOGRAPHY ---
  Widget _buildTypographyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AppText('Typography System', type: AppTextType.title2, fontWeight: FontWeight.bold),
        const SizedBox(height: 16),
        AppGroupedList(
          children: AppTextType.values.map((type) {
            return AppGroupedListTile(
              title: type.name.toUpperCase(),
              subtitle: 'Size details and styles',
              trailing: AppText(
                'Sample Text',
                type: type,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- TAB 2: BUTTONS & SPLITBUTTONS ---
  Widget _buildButtonsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AppText('AppButton Showcase', type: AppTextType.title2, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        ...ButtonVariant.values.map((variant) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
                child: AppText(
                  'Variant: ${variant.name.toUpperCase()}',
                  type: AppTextType.headline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppGroupedList(
                children: [
                  AppGroupedListTile(
                    title: 'Small size',
                    trailing: AppButton(
                      label: 'Small',
                      size: ButtonSize.small,
                      variant: variant,
                      onPressed: () {},
                    ),
                  ),
                  AppGroupedListTile(
                    title: 'Medium size (Default)',
                    trailing: AppButton(
                      label: 'Medium',
                      size: ButtonSize.medium,
                      variant: variant,
                      onPressed: () {},
                    ),
                  ),
                  AppGroupedListTile(
                    title: 'Large size',
                    trailing: AppButton(
                      label: 'Large',
                      size: ButtonSize.large,
                      variant: variant,
                      onPressed: () {},
                    ),
                  ),
                  AppGroupedListTile(
                    title: 'Icon Only',
                    trailing: AppButton(
                      icon: Icons.star,
                      size: ButtonSize.iconOnly,
                      variant: variant,
                      onPressed: () {},
                    ),
                  ),
                  AppGroupedListTile(
                    title: 'With Leading Icon',
                    trailing: AppButton(
                      label: 'Star',
                      icon: Icons.star,
                      size: ButtonSize.medium,
                      variant: variant,
                      onPressed: () {},
                    ),
                  ),
                  AppGroupedListTile(
                    title: 'Ghost Style (Transparent BG)',
                    trailing: AppButton(
                      label: 'Ghost',
                      size: ButtonSize.medium,
                      variant: variant,
                      isGhost: true,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          );
        }),

        const SizedBox(height: 32),

        const AppText('SplitButton Showcase', type: AppTextType.title2, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        ...SplitButtonVariant.values.map((variant) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
                child: AppText(
                  'Variant: ${variant.name.toUpperCase()}',
                  type: AppTextType.headline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppGroupedList(
                children: [
                  AppGroupedListTile(
                    title: 'Small size',
                    trailing: SplitButton(
                      label: 'Small',
                      size: SplitButtonSize.small,
                      variant: variant,
                      onPressed: () {},
                      menuItems: [
                        AppMenuItem(label: 'Option 1', onPressed: () => Navigator.pop(context)),
                        AppMenuItem(label: 'Option 2', onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  AppGroupedListTile(
                    title: 'Medium size',
                    trailing: SplitButton(
                      label: 'Medium',
                      size: SplitButtonSize.medium,
                      variant: variant,
                      onPressed: () {},
                      menuItems: [
                        AppMenuItem(label: 'Action A', onPressed: () => Navigator.pop(context)),
                        AppMenuItem(label: 'Action B', onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  AppGroupedListTile(
                    title: 'Large size',
                    trailing: SplitButton(
                      label: 'Large',
                      size: SplitButtonSize.large,
                      variant: variant,
                      onPressed: () {},
                      menuItems: [
                        AppMenuItem(label: 'Choice X', onPressed: () => Navigator.pop(context)),
                        AppMenuItem(label: 'Choice Y', onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  // --- TAB 3: STEPPERS & HEADERS ---
  Widget _buildSteppersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AppText('AppStepper Controls', type: AppTextType.title2, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        AppGroupedList(
          children: [
            AppGroupedListTile(
              title: 'Standard Stepper',
              subtitle: 'Current value: $_stepperVal1',
              trailing: AppStepper(
                onIncrement: () => setState(() => _stepperVal1++),
                onDecrement: () => setState(() => _stepperVal1--),
              ),
            ),
            AppGroupedListTile(
              title: 'Conditional Stepper',
              subtitle: 'Min 0, Max 5: $_stepperVal2',
              trailing: AppStepper(
                onIncrement: _stepperVal2 < 5 ? () => setState(() => _stepperVal2++) : null,
                onDecrement: _stepperVal2 > 0 ? () => setState(() => _stepperVal2--) : null,
              ),
            ),
            const AppGroupedListTile(
              title: 'Fully Disabled Stepper',
              subtitle: 'Passing null callbacks',
              trailing: AppStepper(
                onIncrement: null,
                onDecrement: null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        const AppText('AppHeader Varian Showcase', type: AppTextType.title2, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),

        const AppText('1. Compact Large Variant (Default)', type: AppTextType.headline),
        const SizedBox(height: 8),
        Container(
          color: Colors.white,
          child: AppHeader(
            title: 'Compact Large',
            variant: AppHeaderVariant.compactLarge,
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {},
            ),
          ),
        ),

        const SizedBox(height: 16),

        const AppText('2. Large Variant (Stacked Layout)', type: AppTextType.headline),
        const SizedBox(height: 8),
        Container(
          color: Colors.white,
          child: AppHeader(
            title: 'Large Title',
            variant: AppHeaderVariant.large,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {},
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
        ),

        const SizedBox(height: 16),

        const AppText('3. Inline Variant (Centered Small Title)', type: AppTextType.headline),
        const SizedBox(height: 8),
        Container(
          color: Colors.white,
          child: AppHeader(
            title: 'Inline Title',
            variant: AppHeaderVariant.inline,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            trailing: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 4: LISTS & DIALOGS ---
  Widget _buildListsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AppText('AppGroupedList Form Types', type: AppTextType.title2, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        AppGroupedList(
          children: [
            AppGroupedListTile(
              title: 'Standard Row',
              detail: 'Simple info',
              onTap: () {},
            ),
            AppGroupedListTile(
              title: 'Notification System',
              subtitle: 'Allow app permissions',
              showChevron: true,
              onTap: () {},
            ),
            AppGroupedListTile(
              title: 'User Profile (Image Leading)',
              subtitle: 'Active premium membership',
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://placehold.co/68x68.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () {},
            ),
            AppGroupedListTile(
              title: 'Select Term',
              badgeLabel: 'June 2024',
              onTap: () {},
            ),
            AppGroupedListTile(
              title: 'Selected Config',
              showCheckmark: true,
              onTap: () {},
            ),
            AppGroupedListTile(
              title: 'System Auto-sync',
              trailing: Switch(
                value: true,
                onChanged: (val) {},
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        const AppText('AppAlertDialog Showcases', type: AppTextType.title2, fontWeight: FontWeight.bold),
        const SizedBox(height: 12),
        AppGroupedList(
          children: [
            AppGroupedListTile(
              title: 'Show Horizontal Layout Dialog',
              subtitle: 'Buttons placed side-by-side',
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                showAppAlertDialog(
                  context,
                  title: 'Discard Changes?',
                  description: 'If you leave this screen, your unsaved progress will be permanently lost.',
                  primaryButtonLabel: 'Discard',
                  onPrimaryPressed: () => Navigator.pop(context),
                  secondaryButtonLabel: 'Cancel',
                  onSecondaryPressed: () => Navigator.pop(context),
                  buttonLayout: AppAlertDialogButtonLayout.horizontal,
                );
              },
            ),
            AppGroupedListTile(
              title: 'Show Vertical Layout Dialog',
              subtitle: 'Buttons stacked vertically',
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                showAppAlertDialog(
                  context,
                  title: 'Account Verification',
                  description: 'Please confirm your identity by picking one of the options below.',
                  primaryButtonLabel: 'Verify ID',
                  onPrimaryPressed: () => Navigator.pop(context),
                  secondaryButtonLabel: 'Cancel',
                  onSecondaryPressed: () => Navigator.pop(context),
                  buttonLayout: AppAlertDialogButtonLayout.vertical,
                );
              },
            ),
            AppGroupedListTile(
              title: 'Show Dialog with Value List Content',
              subtitle: 'Includes custom list items inside body',
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                showAppAlertDialog(
                  context,
                  title: 'Select Items',
                  description: 'The following records will be generated:',
                  content: const AppAlertContentList(
                    items: ['Therapy Record 12', 'Therapy Record 13', 'Therapy Record 14'],
                  ),
                  primaryButtonLabel: 'Accept All',
                  onPrimaryPressed: () => Navigator.pop(context),
                  secondaryButtonLabel: 'Cancel',
                  onSecondaryPressed: () => Navigator.pop(context),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}