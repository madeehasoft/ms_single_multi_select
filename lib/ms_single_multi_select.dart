
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A controller to manage focus and selection state for the multi-select widget.
class MsController {
  final FocusNode focusNode = FocusNode();

  MsClass? selectedSingle;
  List<MsClass> selectedMulti = [];

  void requestFocus() => focusNode.requestFocus();
  void unfocus() => focusNode.unfocus();
  void dispose() => focusNode.dispose();

  bool get isSelected => selectedSingle != null || selectedMulti.isNotEmpty;
}

/// Represents a selectable item used in the single or multi-select dropdown.
///
/// Each item includes a [prefixCode], [name], and [suffixCode] to support
/// flexible display and filtering in the UI.
class MsClass {
  /// The prefix code shown before the item name.
  final String prefixCode;

  /// The main name of the item.
  final String name;

  /// The suffix code shown after the item name.
  final String suffixCode;

  /// Creates a new [MsClass] with the given [prefixCode], [name], and [suffixCode].
  const MsClass({
    required this.prefixCode,
    required this.name,
    required this.suffixCode,
  });

  /// Compares two [MsClass] instances for equality based on their fields.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MsClass &&
          prefixCode == other.prefixCode &&
          name == other.name &&
          suffixCode == other.suffixCode;

  /// Generates a hash code based on [prefixCode], [name], and [suffixCode].
  @override
  int get hashCode => prefixCode.hashCode ^ name.hashCode ^ suffixCode.hashCode;
}

class MsSingleMultiSelector extends StatefulWidget {
  final List<MsClass> items;
  final bool multiSelect;
  final void Function(MsClass)? onChangedSingle;
  final void Function(List<MsClass>)? onChangedMulti;
  final void Function()? onSubmit;
  final MsController? controller;
  final TextStyle? textStyle;
  final TextStyle? searchTextStyle;
  final TextStyle? prefixCodeTextStyle;
  final TextStyle? listNameTextStyle;
  final TextStyle? suffixCodeTextStyle;
  final String? hintText;
  final Icon? prefixIcon;
  final Color? highlightColor;
  final Color? checkboxActiveColor;
  final double? msFieldwidth;
  final double? msFieldheight;

  const MsSingleMultiSelector({
    super.key,
    required this.items,
    this.multiSelect = false,
    this.onChangedSingle,
    this.onChangedMulti,
    this.onSubmit,
    this.controller,
    this.textStyle,
    this.searchTextStyle,
    this.prefixCodeTextStyle,
    this.listNameTextStyle,
    this.suffixCodeTextStyle,
    this.hintText,
    this.prefixIcon,
    this.highlightColor,
    this.checkboxActiveColor,
    this.msFieldwidth,
    this.msFieldheight,
  });

  @override
  State<MsSingleMultiSelector> createState() => _MsSingleMultiSelectorState();
}

class _MsSingleMultiSelectorState extends State<MsSingleMultiSelector> {
  MsClass? selectedCity;
  List<MsClass> selectedCities = [];

  FocusNode get _focusNode => widget.controller?.focusNode ?? FocusNode();

  Future<void> _openDialog(String searchQuery) async {
    final result = await _showCityDialog(
      context: context,
      items: widget.items,
      multiSelect: widget.multiSelect,
      searchTextStyle: widget.searchTextStyle,
      prefixCodeTextStyle: widget.prefixCodeTextStyle,
      listNameTextStyle: widget.listNameTextStyle,
      suffixCodeTextStyle: widget.suffixCodeTextStyle,
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon,
      initialSelected: selectedCities,
      highlightColor: widget.highlightColor,
      checkboxActiveColor: widget.checkboxActiveColor,
      initialSearchQuery: searchQuery, // 👈 Add this parameter to your dialog
    );

    if (result != null) {
      if (widget.multiSelect && result is List<MsClass>) {
        setState(() {
          selectedCities = result;
        });
        widget.controller?.selectedMulti = result; // 👈 Sync with controller
        widget.onChangedMulti?.call(result);
      } else if (result is MsClass) {
        setState(() {
          selectedCity = result;
        });
        widget.controller?.selectedSingle = result; // 👈 Sync with controller
        widget.onChangedSingle?.call(result);
      }
      widget.onSubmit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.multiSelect
        ? selectedCities
              .map((c) => '${c.prefixCode} - ${c.name} (${c.suffixCode})')
              .join(', ')
        : selectedCity == null
        ? ''
        : '${selectedCity!.prefixCode} - ${selectedCity!.name} (${selectedCity!.suffixCode})';
    return SizedBox(
      width: widget.msFieldwidth,
      height: widget.msFieldheight,
      child: TextField(
        readOnly: false,
        style: widget.searchTextStyle ?? const TextStyle(fontSize: 16),
        focusNode: _focusNode,
        onSubmitted: (value) {
          _openDialog(value);
        },
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon ?? const Icon(Icons.location_city),
          suffixIcon: IconButton(
            onPressed: () {
              _openDialog('');
            },
            icon: const Icon(Icons.menu_open),
          ),
          hintText: widget.hintText ?? 'Select a item',
          border: OutlineInputBorder(
            // 👈 Box-style border
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white, // Optional: background color
        ),
        controller: TextEditingController(text: displayText),
        //style: widget.textStyle ?? const TextStyle(fontSize: 16),
      ),
    );
  }
}

Future<dynamic> _showCityDialog({
  required BuildContext context,
  required List<MsClass> items,
  bool multiSelect = false,
  TextStyle? searchTextStyle,
  TextStyle? prefixCodeTextStyle,
  TextStyle? listNameTextStyle,
  TextStyle? suffixCodeTextStyle,
  String? hintText,
  Icon? prefixIcon,
  List<MsClass>? initialSelected,
  Color? highlightColor,
  Color? checkboxActiveColor,
  required String initialSearchQuery,
}) async {
  final TextEditingController searchCtrl = TextEditingController(
    text: initialSearchQuery,
  );
  final FocusNode searchFocusNode = FocusNode();
  List<MsClass> filtered = List.from(items);
  bool initialized = false;
  int highlighted = 0;
  final ScrollController listController = ScrollController();
  const double itemHeight = 50.0;
  final Set<MsClass> selectedCities = initialSelected?.toSet() ?? {};

  Future<void> scrollToHighlighted() async {
    if (!listController.hasClients) return;
    final double target = (highlighted * itemHeight).clamp(
      0.0,
      listController.position.maxScrollExtent,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!listController.hasClients) return;
      listController.animateTo(
        target,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    });
  }

  return showDialog<dynamic>(
    context: context,
    builder: (outerContext) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          FocusScope.of(outerContext).requestFocus(searchFocusNode);
        } catch (_) {}
      });

      return StatefulBuilder(
        builder: (innerContext, setState) {
          void applyFilter(String q) {
            final ql = q.toLowerCase();
            filtered = items
                .where(
                  (e) =>
                      e.name.toLowerCase().contains(ql) ||
                      e.prefixCode.toLowerCase().contains(ql) ||
                      e.suffixCode.toLowerCase().contains(ql),
                )
                .toList();
            highlighted = (filtered.isNotEmpty) ? 0 : -1;
            scrollToHighlighted();
          }

          if (!initialized) {
            applyFilter(initialSearchQuery);
            initialized = true;
          }

          void toggleSelection(MsClass mdData) {
            setState(() {
              if (selectedCities.contains(mdData)) {
                selectedCities.remove(mdData);
              } else {
                selectedCities.add(mdData);
              }
            });
          }

          final double dialogWidth = MediaQuery.of(outerContext).size.width / 2;
          final double dialogHeight =
              MediaQuery.of(outerContext).size.height / 2;

          return Dialog(
            child: KeyboardListener(
              focusNode: FocusNode(),
              autofocus: true,
              onKeyEvent: (KeyEvent event) {
                if (event is! KeyDownEvent) return;
                final key = event.logicalKey;
                if (key == LogicalKeyboardKey.arrowDown) {
                  if (filtered.isNotEmpty) {
                    setState(() {
                      highlighted = (highlighted + 1).clamp(
                        0,
                        filtered.length - 1,
                      );
                    });
                    scrollToHighlighted();
                  }
                } else if (key == LogicalKeyboardKey.arrowUp) {
                  if (filtered.isNotEmpty) {
                    setState(() {
                      highlighted = (highlighted - 1).clamp(
                        0,
                        filtered.length - 1,
                      );
                    });
                    scrollToHighlighted();
                  }
                } else if (key == LogicalKeyboardKey.enter ||
                    key == LogicalKeyboardKey.numpadEnter) {
                  if (highlighted >= 0 && highlighted < filtered.length) {
                    final mdData = filtered[highlighted];
                    if (multiSelect) {
                      toggleSelection(mdData);
                    } else {
                      FocusScope.of(outerContext).unfocus();
                      Navigator.of(outerContext).pop(mdData);
                    }
                  }
                } else if (key == LogicalKeyboardKey.escape) {
                  Navigator.of(outerContext).pop();
                }
              },
              child: SizedBox(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        focusNode: searchFocusNode,
                        controller: searchCtrl,
                        style: searchTextStyle ?? const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          prefixIcon: prefixIcon ?? const Icon(Icons.search),
                          hintText:
                              hintText ?? 'Search by name or prefixCode...',
                          suffixIcon: multiSelect
                              ? Checkbox(
                                  value:
                                      selectedCities.length ==
                                          filtered.length &&
                                      filtered.isNotEmpty,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        selectedCities.addAll(filtered);
                                      } else {
                                        selectedCities.removeWhere(
                                          (mdData) => filtered.contains(mdData),
                                        );
                                      }
                                    });
                                  },
                                  activeColor:
                                      checkboxActiveColor ??
                                      Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                        onChanged: (v) {
                          setState(() {
                            applyFilter(v);
                          });
                        },
                        onSubmitted: (_) {
                          if (!multiSelect && filtered.isNotEmpty) {
                            setState(() {
                              highlighted = 0;
                            });
                            scrollToHighlighted();
                          }
                        },
                      ),
                    ),
                    // if (multiSelect)
                    SizedBox(
                      height: dialogHeight,
                      child: filtered.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('No results'),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              controller: listController,
                              itemExtent: itemHeight,
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final mdData = filtered[i];
                                final isHighlighted = i == highlighted;
                                final isSelected = selectedCities.contains(
                                  mdData,
                                );
                                return InkWell(
                                  onTap: () {
                                    if (multiSelect) {
                                      toggleSelection(mdData);
                                    } else {
                                      FocusScope.of(outerContext).unfocus();
                                      Navigator.of(outerContext).pop(mdData);
                                    }
                                  },
                                  child: Container(
                                    color: isHighlighted
                                        ? (highlightColor ??
                                              Colors.blue.shade100)
                                        : null,

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        if (multiSelect)
                                          Icon(
                                            isSelected
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            //color: isSelected ? Colors.blue : Colors.grey,
                                            color:
                                                checkboxActiveColor ??
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        if (multiSelect)
                                          const SizedBox(width: 8),
                                        Text(
                                          mdData.prefixCode,
                                          style:
                                              prefixCodeTextStyle ??
                                              const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          mdData.name,
                                          style:
                                              listNameTextStyle ??
                                              const TextStyle(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          mdData.suffixCode,
                                          style:
                                              suffixCodeTextStyle ??
                                              const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              FocusScope.of(outerContext).unfocus();
                              Navigator.of(outerContext).pop();
                            },
                            child: const Text(
                              'CANCEL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (multiSelect)
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: outerContext,
                                  builder: (_) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        final selectedList = selectedCities
                                            .toList();
                                        return AlertDialog(
                                          title: const Text('Selected Items'),
                                          content: SizedBox(
                                            width: dialogWidth * 0.8,
                                            height: dialogHeight * 0.6,
                                            child: selectedList.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                      'No item selected.',
                                                    ),
                                                  )
                                                : Scrollbar(
                                                    thumbVisibility: true,
                                                    child: ListView.builder(
                                                      itemCount:
                                                          selectedList.length,
                                                      itemBuilder: (context, index) {
                                                        final mdData =
                                                            selectedList[index];
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 4.0,
                                                                horizontal: 4.0,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Checkbox(
                                                                value: true,
                                                                onChanged: (_) {
                                                                  setState(() {
                                                                    selectedCities
                                                                        .remove(
                                                                          mdData,
                                                                        );
                                                                  });
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                mdData
                                                                    .prefixCode,
                                                                style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  mdData.name,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text(
                                                'CLOSE',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'VIEW SELECTED (${selectedCities.length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          if (multiSelect)
                            TextButton(
                              onPressed: () {
                                FocusScope.of(outerContext).unfocus();
                                Navigator.of(
                                  outerContext,
                                ).pop(selectedCities.toList());
                              },
                              child: const Text(
                                'DONE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
