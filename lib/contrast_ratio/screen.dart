import 'package:colorstudio/contrast_ratio/dark_mode_surface_contrast.dart';
import 'package:colorstudio/contrast_ratio/widgets/contrast_widgets.dart';
import 'package:colorstudio/example/blocs/blocs.dart';
import 'package:colorstudio/example/blocs/contrast_ratio/contrast_ratio_state.dart';
import 'package:colorstudio/example/util/constants.dart';
import 'package:colorstudio/example/widgets/loading_indicator.dart';
import 'package:colorstudio/widgets/section_card.dart';
import 'package:colorstudio/widgets/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hsluv/hsluvcolor.dart';

class ContrastRatioScreen extends StatelessWidget {
  const ContrastRatioScreen(
    this.rgbColorsWithBlindness,
    this.shouldDisplayElevation,
    this.locked,
  );

  final Map<String, Color> rgbColorsWithBlindness;
  final Map<String, bool> locked;
  final bool shouldDisplayElevation;

  @override
  Widget build(BuildContext context) {
    final surfaceHSLuv =
        HSLuvColor.fromColor(rgbColorsWithBlindness[kBackground]);

    final colorScheme = ColorScheme.dark(
      primary: rgbColorsWithBlindness[kPrimary],
      background: surfaceHSLuv.withLightness(10).toColor(),
      surface: rgbColorsWithBlindness[kSurface],
    );

    return BlocBuilder<ContrastRatioBloc, ContrastRatioState>(
        builder: (context, state) {
      if (state is InitialContrastRatioState) {
        return Center(child: LoadingIndicator());
      }

      final currentState = (state as ContrastRatioSuccess);

      final isiPad = MediaQuery.of(context).size.width > 600;

      final areValuesLocked =
          locked[kSurface] == true && locked[kBackground] == true;

      return Theme(
        data: ThemeData.from(
          colorScheme: colorScheme,
          textTheme: TextTheme(
            body1: GoogleFonts.firaSans(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            title: GoogleFonts.firaSans(fontWeight: FontWeight.w600),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: (isiPad == true) ? 24.0 : 16.0,
            right: isiPad ? 8.0 : 16.0,
          ),
          child: SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TitleBar(
                  title: "Contrast Ratio",
                  children: <Widget>[
                    IconButton(
                      tooltip: "Contrast compare",
                      icon: Icon(
                        FeatherIcons.menu,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          "/multiplecontrastcompare",
                        );
                      },
                    ),
                    IconButton(
                      tooltip: "Help",
                      icon: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return _HelpDialog(
                                background: colorScheme.background,
                              );
                            });
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 0,
                  indent: 1,
                  endIndent: 1,
                  color: colorScheme.onSurface.withOpacity(0.30),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ContrastCircleBar(
                      title: kPrimary,
                      subtitle: kBackground,
                      contrast: currentState.contrastValues[0],
                      contrastingColor: rgbColorsWithBlindness[kPrimary],
                      circleColor: rgbColorsWithBlindness[kBackground],
                    ),
                    if (!areValuesLocked) ...[
                      ContrastCircleBar(
                        title: kPrimary,
                        subtitle: kSurface,
                        contrast: currentState.contrastValues[1],
                        contrastingColor: rgbColorsWithBlindness[kPrimary],
                        circleColor: rgbColorsWithBlindness[kSurface],
                      ),
                      ContrastCircleBar(
                        title: kSurface,
                        subtitle: kBackground,
                        contrast: currentState.contrastValues[2],
                        contrastingColor: rgbColorsWithBlindness[kSurface],
                        circleColor: rgbColorsWithBlindness[kBackground],
                      ),
                    ],
                  ],
                ),
                // surface qualifies as dark mode
                Text(
                  "Primary / Surface with elevation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (shouldDisplayElevation) ...[
                  SizedBox(height: 8),
                  DarkModeSurfaceContrast(currentState.elevationValues),
                ] else ...[
                  SizedBox(
                    height: 128,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "In dark surfaces, Material Design Components express depth by displaying lighter surface colors. "
                            "The higher a surface’s elevation (raising it closer to an implied light source), the lighter that surface becomes.\n",
                            style: Theme.of(context).textTheme.caption.copyWith(
                                  color: Colors.white.withOpacity(0.70),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "You are using a light surface color.",
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  )
                ],
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _HelpDialog extends StatelessWidget {
  const _HelpDialog({this.background});

  final Color background;

  @override
  Widget build(BuildContext context) {
    /// I am REALLY NOT PROUD of this class!
    /// Really wish Flutter had a better Markdown support.
    /// The existing package was really buggy, so this approach was necessary.
    return AlertDialog(
      title: const Text("Contrast Ratio"),
      contentPadding: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: background,
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // good resources:
                  // https://www.w3.org/TR/WCAG21/#contrast-minimum
                  // https://usecontrast.com/guide
                  // https://material.io/design/color/dark-theme.html
                  // https://blog.cloudflare.com/thinking-about-color/
                  Text(
                    "WACG recommends a contrast of:",
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "3.0:1 minimum for texts larger than 18pt or icons (AA+).\n4.5:1 minimum for texts smaller than 18pt (AA).\n7.0:1 minimum when possible, if possible (AAA).",
                  ),
                  Text(
                    "\nMost design specifications, including Material, follow this.",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    "There is a formula that calculates the apparent contrast between two colors.",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Surface with elevation",
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "In a dark theme, at higher levels of elevation, Material Design Components express depth by displaying a lighter surface color. " +
                        "The higher a surface’s elevation (raising it closer to an implied light source), the lighter that surface becomes. " +
                        "That lightness is expressed through the application of a semi-transparent overlay using the OnSurface color (default: white).",
                  ),
                  SizedBox(height: 24),
                  Text(
                    "HSLuv",
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This app makes heavy usage of HSLuv."
                    " RGB is unintuitive, HSV and HSL are flawed. When you change the Hue or Saturation in them, the appearent lightness also changes. ",
                  ),
                  SizedBox(height: 8),
                  Text(
                    "HSLuv extends CIELUV, which was based on human experiments, for a perceptual uniform color model." +
                        " This means: when you change the Hue or Saturation in HSLuv, the appearent/perceptual lightness will not vary wildly. This makes a lot easier to design color systems, since you can adjust a color without changing the contrast.",
                  ),
                  Text(
                    "\nYou are seeing HSLuv in action right now!",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    "This background color is Color Scheme's Background color with Lightness = 20.",
                    style: Theme.of(context).textTheme.caption,
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
