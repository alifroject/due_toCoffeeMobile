import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '10:20',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Inria Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            width: 64,
            height: 21,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF110F0F),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          Row(
            children: [
              Image.network(
                'https://cdn.builder.io/api/v1/image/assets/TEMP/a30826ea5b26baf6f3086fdaa9abc9bc899e8ec7?placeholderIfAbsent=true&apiKey=533b204a865e416d87d00b3e64c64775',
                width: 32,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Image.network(
                'https://cdn.builder.io/api/v1/image/assets/TEMP/6c592e7984591467a9ba22e720d15ffbfa1fea54?placeholderIfAbsent=true&apiKey=533b204a865e416d87d00b3e64c64775',
                width: 29,
                height: 27,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}