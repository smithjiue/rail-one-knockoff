import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rail_one/core/theme/app_colors.dart';

class MpinInputRow extends StatefulWidget {
  const MpinInputRow({super.key, required this.onCompleted, this.length = 6});

  final ValueChanged<String> onCompleted;
  final int length;

  @override
  State<MpinInputRow> createState() => _MpinInputRowState();
}

class _MpinInputRowState extends State<MpinInputRow> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits != value) {
      _controller.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }
    setState(() {});
    if (digits.length == widget.length) {
      widget.onCompleted(digits);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final boxSize =
        (MediaQuery.sizeOf(context).width - 40 - (widget.length - 1) * 8) /
        widget.length;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final filled = index < code.length;
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                child: Container(
                  width: boxSize.clamp(44.0, 52.0),
                  height: boxSize.clamp(44.0, 52.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: filled
                          ? AppColors.authPrimary
                          : const Color(0xFFB8DCFA),
                      width: 1.2,
                    ),
                  ),
                  child: filled
                      ? const Text(
                          '•',
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.authPrimaryDark,
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),
          Opacity(
            opacity: 0.01,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              autofocus: true,
              obscureText: true,
              obscuringCharacter: '•',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: _onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
