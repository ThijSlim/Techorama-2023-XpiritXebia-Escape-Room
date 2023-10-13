import 'package:escape_room_game/views/game/active_game/numerical-input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../providers/ip-address-provider.dart';

class NetworkAddress extends ConsumerStatefulWidget {
  const NetworkAddress({Key? key}) : super(key: key);

  @override
  ConsumerState<NetworkAddress> createState() => _NetworkAddressState();
}

class _NetworkAddressState extends ConsumerState<NetworkAddress> {

  final TextEditingController _controller = TextEditingController(text: "192.168.1.138");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          // Network ip address input
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // white background
              TextField(

                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  labelText: 'Backend ip address',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  container.read(backendIpAddressStateProvider.notifier).setIpAddress(_controller.text);
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('Continue', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
