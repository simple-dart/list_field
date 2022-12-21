import 'dart:html';

import 'package:simple_dart_image_button/simple_dart_image_button.dart';
import 'package:simple_dart_label/simple_dart_label.dart';
import 'package:simple_dart_text_field/simple_dart_text_field.dart';
import 'package:simple_dart_ui_core/simple_dart_ui_core.dart';

typedef ValidatorFunc = bool Function(List<String> oldValues, String newRow);

class ListField extends PanelComponent
    with ValueChangeEventSource<List<String>>
    implements StateComponent<List<String>> {
  ListField() : super('ListField') {
    vertical = true;
    spacing = '3px';
    addButton.onClick.listen((event) {
      final newRow = addField.value;
      if (newRow.isEmpty) {
        return;
      }
      final oldValue = value;
      var valid = true;
      if (validator != null) {
        valid = validator!(oldValue, newRow);
      }
      if (valid) {
        addRow(newRow);
        addField.value = '';
        fireValueChange(oldValue, value);
      }
    });
    addPanel.addAll([addField, addButton]);

    addAll([valueListPanel, addPanel]);
  }

  bool _disabled = false;

  bool get disabled => _disabled;

  set disabled(bool newVal) {
    _disabled = newVal;
    for (final row in valueListPanel.children) {
      if (row is ListFieldRow) {
        row.removeButton.disabled = newVal;
        if (newVal) {
          row.valueLabel.addCssClass('Disabled');
        } else {
          row.valueLabel.removeCssClass('Disabled');
        }
      }
    }
    addButton.disabled = newVal;
    addField.disabled = newVal;
  }

  void focus() {
    addField.focus();
  }

  ValidatorFunc? validator;

  TextField addField = TextField()
    ..fullWidth()
    ..fillContent = true;
  ImageButton addButton = ImageButton()
    ..source = 'images/add.svg'
    ..width = '16px';
  Panel addPanel = Panel()..spacing = '5px';
  Panel valueListPanel = Panel()
    ..vertical = true
    ..spacing = '2px';

  List<String> get value => valueListPanel.children.map((e) {
        if (e is ListFieldRow) {
          return e.value;
        } else {
          return '';
        }
      }).toList();

  set value(List<String> newValue) {
    final oldValue = value;
    if (newValue.length < valueListPanel.children.length) {
      for (var i = newValue.length; i < valueListPanel.children.length; i++) {
        valueListPanel.removeComponent(valueListPanel.children[i]);
      }
    }
    var i = 0;
    for (final valuePanel in valueListPanel.children) {
      if (valuePanel is ListFieldRow) {
        valuePanel.value = newValue[i];
      }
      i++;
    }
    if (newValue.length > valueListPanel.children.length) {
      for (; i < newValue.length; i++) {
        addRow(newValue[i]);
      }
    }
    fireValueChange(oldValue, newValue);
  }

  @override
  String get state => value.join(',');

  @override
  set state(String newValue) => value = newValue.split(',');

  void addRow(String row) {
    final newRowPanel = ListFieldRow()..value = row;
    newRowPanel.onRemove = (e) {
      final oldValue = value;
      valueListPanel.removeComponent(newRowPanel);
      fireValueChange(oldValue, value);
    };
    valueListPanel.add(newRowPanel);
  }
}

class ListFieldRow extends PanelComponent {
  ListFieldRow() : super('ListFieldRow') {
    spacing = '3px';
    removeButton.onClick.listen((event) {
      if (onRemove != null) {
        onRemove!(event);
      }
    });
    vAlign = Align.center;
    add(removeButton);
    add(valueLabel);
  }

  ImageButton removeButton = ImageButton()
    ..addCssClass('RemoveButton')
    ..source = 'images/remove_icon.svg'
    ..height = '16px';

  Label valueLabel = Label()
    ..fillContent = true
    ..fullWidth();

  Function(MouseEvent event)? onRemove;

  set value(String newValue) {
    valueLabel.caption = newValue;
  }

  String get value => valueLabel.caption;
}
