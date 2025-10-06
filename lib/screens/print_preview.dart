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

  String getMonthYear(DateTime date) {
    return DateFormat.yMMMM().format(date);
  }

  Future<void> _saveAsPdf(BuildContext context, String title,
      List<Transaction> transactions) async {
    setState(() {
      isSaving = true;
    });
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              children: [
                pw.Text(title,
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
                pw.SizedBox(height: 16),
                pw.Expanded(
                  child: pw.ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => pw.Divider(),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            DateFormat('dd MMM yyyy').format(tx.date),
                            style: const pw.TextStyle(
                                fontSize: 14, color: PdfColors.grey600),
                          ),
                          pw.Text(
                            '${tx.karat} Karat',
                            style: const pw.TextStyle(
                                fontSize: 14, color: PdfColors.grey600),
                          ),
                          pw.Text(
                            '${tx.weight.toStringAsFixed(2)}g',
                            style: const pw.TextStyle(
                                fontSize: 14, color: PdfColors.grey600),
                          ),
                          pw.Text(
                            '${currencyFormatter(tx.totalAmount).substring(0, (currencyFormatter(tx.totalAmount).length - 3))} Birr',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                pw.SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );

    try {
      //saving
      final dir = await getApplicationDocumentsDirectory();
      final sanitizedTitle = title.replaceAll(RegExp(r"[^\w\s-]"), "_");
      final filePath = '${dir.path}/$sanitizedTitle.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      //sharing
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: '$sanitizedTitle.pdf');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved to: $filePath')),
        );
      }
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
                separatorBuilder: (_, __) => const Divider(),
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
            isSaving
                ? FancyWideButton('Saving...', () {})
                : FancyWideButton('Print', () async {
                    // await _requestStoragePermission(context);
                    if (context.mounted) {
                      await _saveAsPdf(context, title, widget.transactions);
                    }
                  })
          ],
        ),
      ),
    );
  }
}
