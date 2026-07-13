import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/button.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/component/auth_bottom_sheet.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class WelcomeScreens extends StatelessWidget {
  const WelcomeScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'lib/asset/ChatGPT Image 9 Jul 2026, 14.21.12.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: context.colors.backgroundsPrimary.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.5
                  : 0.2,
            ), // Dynamic overlay tint for readability
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // First Container: Title & Description (Container 1)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align to left
                      children: [
                        SizedBox(
                          width: 408,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Reliable System ',
                                  style: TextStyle(
                                    color: context.colors.labelsPrimary,
                                    fontSize: 32,
                                    fontFamily: 'SF Pro',
                                    fontWeight:
                                        FontWeight.w600, // Close to w590
                                    height: 1.2,
                                    letterSpacing: -0.43,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Access',
                                  style: TextStyle(
                                    color: context.colors.labelsPrimary,
                                    fontSize: 32,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'SF Pro',
                                    fontWeight:
                                        FontWeight.w500, // Close to w508
                                    height: 1.2,
                                    letterSpacing: -0.43,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left, // Align text to left
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 408,
                          child: AppText(
                            'Stay connected with your devices anytime',
                            type: AppTextType.callout, // 16px
                            customColor: context.colors.labelsPrimary,
                            textAlign:
                                TextAlign.left, // Align description to left
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Second Container: Get Started Button & Sign In Option (Container 2)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 40,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            label: 'Get Started',
                            size: ButtonSize.large, // height 50px
                            variant: ButtonVariant.primary,
                            onPressed: () {
                              AuthBottomSheet.show(
                                context,
                                initialMode: AuthMode.signUp,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppText(
                              'Already have an account? ',
                              type: AppTextType.subheadline,
                              customColor: context
                                  .colors
                                  .labelsSecondary, // Sits on light blurred overlay
                            ),
                            GestureDetector(
                              onTap: () {
                                AuthBottomSheet.show(
                                  context,
                                  initialMode: AuthMode.login,
                                );
                              },
                              child: AppText(
                                'Sign In',
                                type: AppTextType.subheadline,
                                customColor: context.colors.accentsBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
