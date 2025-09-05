import 'package:flutter/material.dart';

class FixedTable extends StatefulWidget {
  final int rowCount;
  final int colCount;
  final double cellWidth;
  final double cellHeight;
  final double? fixedFirstColumnWidth;
  final bool enableHorizontalScroll;
  final Widget Function(int row, int col)? cellBuilder;
  final Widget Function(int col)? headerBuilder;
  final Widget Function(int row)? fixedColumnBuilder;
  final Function(ScrollController verticalController, ScrollController verticalControllerFixed)? onControllersReady;

  const FixedTable({
    super.key,
    required this.rowCount,
    required this.colCount,
    this.cellWidth = 80,
    this.cellHeight = 40,
    this.fixedFirstColumnWidth,
    this.enableHorizontalScroll = false,
    this.cellBuilder,
    this.headerBuilder,
    this.fixedColumnBuilder,
    this.onControllersReady,
  });

  @override
  State<FixedTable> createState() => _FixedTableState();
}

class _FixedTableState extends State<FixedTable> {
  late final ScrollController _verticalController;
  late final ScrollController _verticalControllerFixed;
  late final ScrollController _horizontalHeaderController;
  late final ScrollController _horizontalBodyController;

  @override
  void initState() {
    super.initState();
    _verticalController = ScrollController();
    _verticalControllerFixed = ScrollController();
    _horizontalHeaderController = ScrollController();
    _horizontalBodyController = ScrollController();

    // Sincronización vertical (solo para filas no fijas)
    _verticalController.addListener(() {
      if (_verticalControllerFixed.hasClients &&
          _verticalController.offset != _verticalControllerFixed.offset) {
        _verticalControllerFixed.jumpTo(_verticalController.offset);
      }
    });
    _verticalControllerFixed.addListener(() {
      if (_verticalController.hasClients &&
          _verticalControllerFixed.offset != _verticalController.offset) {
        _verticalController.jumpTo(_verticalControllerFixed.offset);
      }
    });
    // Sincronización horizontal
    _horizontalBodyController.addListener(() {
      if (_horizontalHeaderController.hasClients &&
          _horizontalBodyController.offset != _horizontalHeaderController.offset) {
        _horizontalHeaderController.jumpTo(_horizontalBodyController.offset);
      }
    });
    _horizontalHeaderController.addListener(() {
      if (_horizontalBodyController.hasClients &&
          _horizontalHeaderController.offset != _horizontalBodyController.offset) {
        _horizontalBodyController.jumpTo(_horizontalHeaderController.offset);
      }
    });

    // Notificar al widget padre que los controllers están listos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onControllersReady != null) {
        widget.onControllersReady!(_verticalController, _verticalControllerFixed);
      }
    });
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _verticalControllerFixed.dispose();
    _horizontalHeaderController.dispose();
    _horizontalBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cellWidth = widget.cellWidth;
    final fixedColWidth = widget.fixedFirstColumnWidth ?? 64.0;
    final cellHeight = widget.cellHeight;
    final rowCount = widget.rowCount;
    final colCount = widget.colCount;

    Widget buildCell(int row, int col) {
      if (widget.cellBuilder != null) {
        return widget.cellBuilder!(row, col);
      }
      return Container(
        width: cellWidth,
        height: cellHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text('($row, $col)'),
      );
    }

    Widget buildHeader(int col) {
      if (widget.headerBuilder != null) {
        return widget.headerBuilder!(col);
      }
      return Container(
        width: cellWidth,
        height: cellHeight,
        alignment: Alignment.center,
        color: Colors.grey[300],
        child: Text('Día $col'),
      );
    }

    Widget buildFixedColumn(int row) {
      if (widget.fixedColumnBuilder != null) {
        return widget.fixedColumnBuilder!(row);
      }
      return Container(
        width: fixedColWidth,
        height: cellHeight,
        alignment: Alignment.center,
        color: Colors.grey[300],
        child: Text('Fila $row'),
      );
    }

    // Construir fila de alojamiento (fila 0)
    Widget buildAccommodationRow() {
      return Row(
        children: [
          // Columna fija para alojamiento
          buildFixedColumn(0),
          // Celdas de alojamiento
          ...List.generate(colCount, (j) => buildCell(0, j)),
        ],
      );
    }

    // Usar IntrinsicHeight para manejar constraints de altura correctamente
    return IntrinsicHeight(
      child: Column(
        children: [
          // Fila de encabezados
          Row(
            children: [
              // Esquina superior izquierda
              Container(
                width: fixedColWidth,
                height: cellHeight,
                color: Colors.grey[400],
              ),
              // Encabezados de días
              if (widget.enableHorizontalScroll)
                Expanded(
                  child: Scrollbar(
                    controller: _horizontalHeaderController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalHeaderController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(colCount, (j) => buildHeader(j)),
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(colCount, (j) => buildHeader(j)),
            ],
          ),
          // Fila de alojamiento FIJA (no se mueve con scroll vertical)
          buildAccommodationRow(),
          // Cuerpo de la tabla que se adapta al espacio disponible (filas 1 en adelante)
          Expanded(
            child: Row(
              children: [
                // Columna fija de horas (solo para filas no fijas)
                SizedBox(
                  width: fixedColWidth,
                  child: Scrollbar(
                    controller: _verticalControllerFixed,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalControllerFixed,
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: List.generate(rowCount - 1, (i) => buildFixedColumn(i + 1)),
                      ),
                    ),
                  ),
                ),
                // Celdas de la tabla (solo para filas no fijas)
                Expanded(
                  child: Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      scrollDirection: Axis.vertical,
                      child: widget.enableHorizontalScroll
                        ? Scrollbar(
                            controller: _horizontalBodyController,
                            thumbVisibility: true,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                _horizontalBodyController.jumpTo(
                                  _horizontalBodyController.offset - details.delta.dx,
                                );
                              },
                              onVerticalDragUpdate: (details) {
                                _verticalController.jumpTo(
                                  _verticalController.offset - details.delta.dy,
                                );
                              },
                              child: SingleChildScrollView(
                                controller: _horizontalBodyController,
                                scrollDirection: Axis.horizontal,
                                child: Table(
                                  defaultColumnWidth: FixedColumnWidth(cellWidth),
                                  children: List.generate(rowCount - 1, (i) {
                                    return TableRow(
                                      children: List.generate(colCount, (j) => buildCell(i + 1, j)),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          )
                        : Table(
                            defaultColumnWidth: FixedColumnWidth(cellWidth),
                            children: List.generate(rowCount - 1, (i) {
                              return TableRow(
                                children: List.generate(colCount, (j) => buildCell(i + 1, j)),
                              );
                            }),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 