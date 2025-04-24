import 'package:flutter/material.dart';


class LoadingMenuButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final Future<void> Function() onPressed;

  const LoadingMenuButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  State<LoadingMenuButton> createState() => _LoadingMenuButtonState();
}

class _LoadingMenuButtonState extends State<LoadingMenuButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() => isLoading = true);

        await widget.onPressed();

        setState(() => isLoading = false);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          children: [
            Icon(widget.icon, color: Colors.blue),
            const SizedBox(width: 20,),
          Expanded(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          if (isLoading) ...[
        const SizedBox(width: 12),
        const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        ),
        ],
            const SizedBox(width: 75,),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],

        ),
      ),


    );
  }
}