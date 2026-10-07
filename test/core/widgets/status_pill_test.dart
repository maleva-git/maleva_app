import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

import '../../support/local_fonts.dart';

/// Long statuses ("DELIVERY DONE", "WAITING FOR POD") and RTI numbers fit narrow board cells:
/// the pill shrinks with an ellipsis instead of overflowing, and the full text is in a tooltip.
void main() {
  setUpAll(installLocalTestFonts);

  testWidgets('a long status in a narrow cell does not overflow', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Column(children: [
          for (final s in ['ASSIGNED', 'DELIVERY DONE', 'WAITING FOR POD', 'WAITING FOR POD AND CUSTOMER SIGNATURE'])
            SizedBox(width: 110, height: 48, child: Align(alignment: Alignment.centerLeft, child: StatusPill(s))),
          const SizedBox(width: 90, height: 48, child: Align(alignment: Alignment.centerLeft, child: RtiBadge('RTI000012345'))),
        ]),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(Tooltip), findsWidgets);
    expect(find.byTooltip('WAITING FOR POD'), findsOneWidget);
    expect(find.byTooltip('RTI created: RTI000012345'), findsOneWidget);
  });
}
