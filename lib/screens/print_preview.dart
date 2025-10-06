import 'package:nbe/libs.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class PrintPreviewScreen extends StatefulWidget {
  final List<Transaction> transactions;
  const PrintPreviewScreen({required this.transactions, super.key});

  @override
  State<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen> {
  bool isSaving = false;
  bool isSharing = false;
  final List<Setting> settings = [];
  final Setting defaultSeting = Setting('id', 0, 5000, 0.0001, 0.1);

  String getMonthYear(DateTime date) {
    return DateFormat.yMMMM().format(date);
  }

  void _getSettings() async {
    final db = NBEDatabase.constructor([
      SettingLocalProvider.createOrReplaceTableString(),
    ]);
    final newSettings = await SettingLocalProvider(db).getAllSettings();
    setState(() {
      settings.addAll(newSettings);
    });
  }

  Future<pw.Document> _createPdf(BuildContext context, String title,
      List<Transaction> transactions) async {
    final pdf = pw.Document();
    final headersStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 13);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a3,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: 0.5,
                    child: pw.Opacity(
                      opacity: 0.25,
                      child: pw.Text('Gold Purchaser',
                          style: pw.TextStyle(
                              color: PdfColors.amber,
                              fontSize: 80,
                              fontWeight: pw.FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('Transaction Records of ',
                            style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                decoration: pw.TextDecoration.underline,
                                color: PdfColors.black)),
                        pw.Text(title,
                            style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                decoration: pw.TextDecoration.underline,
                                color: PdfColors.black)),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0xFF055fab),
                          border: pw.Border.all(
                              color: const PdfColor.fromInt(0xFF055fab),
                              width: 8)),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Date       ',
                              style: headersStyle,
                            ),
                            pw.Text('Purity', style: headersStyle),
                            pw.Text('Weight', style: headersStyle),
                            pw.Text('Tax    ', style: headersStyle),
                            pw.Text('     Bonus ', style: headersStyle),
                            pw.Text(' Bank Fee', style: headersStyle),
                            pw.Text('Total Amount', style: headersStyle),
                            pw.Text('Status', style: headersStyle),
                          ]),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Expanded(
                      child: pw.ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (ctx, i) => pw.Divider(),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final setting = settings.firstWhere(
                            (setting) => tx.settingId == setting.id,
                            orElse: () => defaultSeting,
                          );
                          final commonStyle = pw.TextStyle(
                              fontSize: 13,
                              color: PdfColors.grey600,
                              fontWeight: pw.FontWeight.bold);
                          return pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                DateFormat('dd MMM yyyy').format(tx.date),
                                style: commonStyle,
                              ),
                              pw.Text(
                                '${tx.karat} Karat',
                                style: commonStyle,
                              ),
                              pw.Text(
                                '${tx.weight.toStringAsFixed(2)}g',
                                style: commonStyle,
                              ),
                              pw.Text(
                                  currencyFormatterForPrint(
                                      tx.weight * setting.taxPerGram),
                                  style: commonStyle),
                              pw.Text(
                                  currencyFormatterForPrint(tx.totalAmount *
                                      setting.excludePercentage),
                                  style: commonStyle),
                              pw.Text(
                                  currencyFormatterForPrint(
                                      setting.bankFeePercentage *
                                          tx.totalAmount),
                                  style: commonStyle),
                              pw.Text(currencyFormatterForPrint(tx.totalAmount),
                                  style: pw.TextStyle(
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black)),
                              pw.Text(tx.isCompleted ? 'Completed' : 'Pending',
                                  style: commonStyle),
                            ],
                          );
                        },
                      ),
                    ),
                    pw.SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  Future<void> _saveAsPdf(BuildContext context, String title,
      List<Transaction> transactions) async {
    setState(() {
      isSaving = true;
    });
    final pdf = await _createPdf(context, title, transactions);
    try {
      //preview
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) => pdf.save());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save PDF: $e')),
        );
      }
    }
    setState(() {
      isSaving = false;
    });
  }

  Future<void> _sharePdf(BuildContext context, String title,
      List<Transaction> transactions) async {
    setState(() {
      isSharing = true;
    });
    final pdf = await _createPdf(context, title, transactions);
    final formattedTitle = title.replaceAll(RegExp(r"[^\w\s-]"), "_");
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: '$formattedTitle.pdf');
    setState(() {
      isSharing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Print Preview')),
        body: const Center(child: Text('No transactions to display')),
      );
    }

    final firstDate = widget.transactions.first.date;
    final title = getMonthYear(firstDate);
    final TextStyle commonLabelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black.withOpacity(.5),
      overflow: TextOverflow.visible,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: widget.transactions.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = widget.transactions[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(tx.date),
                        style: commonLabelStyle,
                      ),
                      Text(
                        '${tx.karat}K',
                        style: commonLabelStyle,
                      ),
                      Text(
                        '${tx.weight.toStringAsFixed(2)}g',
                        style: commonLabelStyle,
                      ),
                      Text(currencyFormatter(tx.totalAmount),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                isSaving
                    ? FilledButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).primaryColor)),
                        onPressed: () {},
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            'Saving...',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ))
                    : FilledButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).primaryColor)),
                        onPressed: () async {
                          if (context.mounted) {
                            await _saveAsPdf(
                                context, title, widget.transactions);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Print',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        )),
                isSharing
                    ? FilledButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).primaryColor)),
                        onPressed: () {},
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            'Sharing...',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ))
                    : FilledButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Theme.of(context).primaryColor)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Share',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ),
                        onPressed: () async {
                          if (context.mounted) {
                            await _sharePdf(
                                context, title, widget.transactions);
                          }
                        },
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
