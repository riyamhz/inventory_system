import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:inventory_system/widget/custom_elevated_button.dart';
import 'package:inventory_system/widget/text_form_field_widget.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  String? docId;
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> addItem({
    required String name,
    required int quantity,
    required double price,
  }) async {
    try {
      List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection');
      }

      DocumentReference<Map<String, dynamic>> newDocRef =
          await FirebaseFirestore.instance.collection('inventory').add({
        'name': name,
        'quantity': quantity,
        'price': price,
      });
      setState(() {
        docId = newDocRef.id;
      });
      log(docId.toString(), name: "documentId");

      productNameController.clear();
      quantityController.clear();
      priceController.clear();
    } catch (e, stackTrace) {
      log(
        e.toString(),
        name: "addItem error",
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateItem({
    required String docId,
    required String name,
    required int quantity,
    required double price,
  }) async {
    await FirebaseFirestore.instance.collection('inventory').doc(docId).update({
      'name': name,
      'quantity': quantity,
      'price': price,
    });
    productNameController.clear();
    quantityController.clear();
    priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  color: Colors.grey.shade100,
                ),
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top,
                ),
                padding: const EdgeInsets.all(8),
                width: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextformfieldWidget(
                      labelText: 'Product Name',
                      controller: productNameController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextformfieldWidget(
                      labelText: 'Quantity',
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextformfieldWidget(
                      labelText: 'price',
                      controller: priceController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomElevatedButton(
                      buttonText: "Add",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          addItem(
                            name: productNameController.text,
                            quantity: int.parse(quantityController.text),
                            price: double.parse(priceController.text),
                          );
                        }
                      },
                    ),
                    CustomElevatedButton(
                      buttonText: "Update",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (docId != null) {
                            updateItem(
                              docId: docId!,
                              name: productNameController.text,
                              quantity: int.parse(quantityController.text),
                              price: double.parse(priceController.text),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('inventory')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No items found.'),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return Flexible(
                    child: ListView.separated(
                      itemCount: docs.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return ListTile(
                          onTap: () {
                            log(docs[index].id.toString());
                            setState(() {
                              productNameController.text =
                                  data['name'].toString();
                              quantityController.text =
                                  data['quantity'].toString();
                              priceController.text = data['price'].toString();
                              docId = docs[index].id.toString();
                            });
                          },
                          title: Text(
                            "Title: ${data['name'].toString()}",
                          ),
                          subtitle: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Quantity: ${data['quantity'].toString()}",
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Price: ${data['price'].toString()}",
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_rounded),
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('inventory')
                                    .doc(docs[index].id)
                                    .delete();
                                log("Deleted: ${docs[index].id}");
                              } catch (e) {
                                log("Delete Error: $e");
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to delete item'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
