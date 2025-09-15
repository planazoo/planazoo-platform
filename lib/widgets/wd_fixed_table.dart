import 'package:flutter/material.dart';

class FixedTable extends StatelessWidget {
  final List<TableColumn> columns;
  final List<TableRow> rows;
  final double? columnWidth;
  final double? rowHeight;

  const FixedTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnWidth,
    this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: _buildColumnWidths(),
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          children: columns.map((column) => 
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                column.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ).toList(),
        ),
        // Data rows
        ...rows,
      ],
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths() {
    final Map<int, TableColumnWidth> columnWidths = {};
    for (int i = 0; i < columns.length; i++) {
      columnWidths[i] = columnWidth != null 
          ? FixedColumnWidth(columnWidth!)
          : const FlexColumnWidth();
    }
    return columnWidths;
  }
}

class TableColumn {
  final String title;
  final double? width;

  const TableColumn({
    required this.title,
    this.width,
  });
}
