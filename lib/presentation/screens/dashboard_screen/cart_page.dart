import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/logic/data/bloc/auth/auth_bloc.dart';
import 'package:mobile/logic/data/bloc/detail_transaction/detail_transaction_bloc.dart';
import 'package:mobile/logic/data/bloc/product/product_bloc.dart';
import 'package:mobile/presentation/screens/checkout_page.dart';
import 'package:mobile/presentation/screens/detail_product_page.dart';
import 'package:mobile/presentation/utils/default.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Let's order fresh items for you
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Keranjang",
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // list view of cart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BlocBuilder<DetailTransactionBloc, DetailTransactionState>(
                builder: (context, state) {
                  if (state is DetailTransactionLoaded) {
                    var checkout = state.data.results!;
                    return checkout.isEmpty
                        ? Center(
                            child: Text('Ayoo beli furniturmu di catalog!'))
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: checkout.length,
                            itemBuilder: (context, index) {
                              return BlocBuilder<ProductBloc, ProductState>(
                                  builder: (_, pstate) {
                                if (pstate is ProductLoaded) {
                                  var product = pstate.productModel.results!
                                      .where((element) =>
                                          element.id ==
                                          state.data.results![index].pivot!
                                              .productId);

                                  return Slidable(
                                    endActionPane: ActionPane(
                                      motion: ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (BuildContext context) =>
                                              deleteItem(product.first.id),
                                          backgroundColor: Color(0xFFb50000),
                                          foregroundColor: Colors.white,
                                          icon: Icons.playlist_remove_outlined,
                                          label: 'Hapus',
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailProduct(
                                                          productId: product
                                                              .first.id!
                                                              .toInt())));
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  product.first.image == null
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: Container(
                                                            height: 100,
                                                            width: 100,
                                                            child: Icon(
                                                              Icons.inventory,
                                                            ),
                                                          ),
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: Image.network(
                                                            "${apiUrlStorage}/${product.first.image}",
                                                            fit: BoxFit.fill,
                                                            height: 100,
                                                            width: 100,
                                                            // Better way to load images from network flutter
                                                            // https://stackoverflow.com/questions/53577962/better-way-to-load-images-from-network-flutter
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  value: loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                  Container(
                                                    height: 100,
                                                    width: 150,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${product.first.name}",
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                        Text(
                                                            "Rp.${product.first.harga},00"),
                                                        Container(
                                                          width: 150,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    var data = {
                                                                      "produc"
                                                                          "t_"
                                                                          "id"
                                                                          "": "${state.data.results![index].id}",
                                                                      "qty":
                                                                          "${checkout[index].pivot!.qty != 1 ? checkout[index].pivot!.qty - 1 : deleteItem(state.data.results![index].id)}",
                                                                      "sub_total":
                                                                          "${
                                                                              checkout[index].harga * (checkout[index].pivot!.qty - 1)}"
                                                                    };
                                                                    final astate = context
                                                                        .read<
                                                                            AuthBloc>()
                                                                        .state;
                                                                    if (astate
                                                                        is AuthLoaded) {
                                                                      print(state
                                                                          .data
                                                                          .results![
                                                                              index]
                                                                          .id);
                                                                      context.read<DetailTransactionBloc>().add(SubstractQTYProductToDetailTransactionList(
                                                                          data,
                                                                          astate
                                                                              .userModel
                                                                              .token));
                                                                    }
                                                                  },
                                                                  icon: Icon(Icons
                                                                      .remove_circle_outline)),
                                                              Text(state
                                                                          .data
                                                                          .results![
                                                                              index]
                                                                          .pivot!
                                                                          .qty ==
                                                                      null
                                                                  ? "0"
                                                                  : state
                                                                      .data
                                                                      .results![
                                                                          index]
                                                                      .pivot!
                                                                      .qty
                                                                      .toString()),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    var data = {
                                                                      "produc"
                                                                          "t_"
                                                                          "id"
                                                                          "": "${state.data.results![index].id}",
                                                                      "qty":
                                                                          "${checkout[index].pivot!.qty + 1}",
                                                                      "sub_total":
                                                                          "${
                                                                              checkout[index].harga * (checkout[index].pivot!.qty + 1)}"
                                                                    };
                                                                    final astate = context
                                                                        .read<
                                                                            AuthBloc>()
                                                                        .state;
                                                                    if (astate
                                                                        is AuthLoaded) {
                                                                      print(state
                                                                          .data
                                                                          .results![
                                                                              index]
                                                                          .id);
                                                                      context.read<DetailTransactionBloc>().add(AddQTYProductToDetailTransactionList(
                                                                          data,
                                                                          astate
                                                                              .userModel
                                                                              .token));
                                                                    }
                                                                  },
                                                                  icon: Icon(Icons
                                                                      .add_circle_outline)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
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
                                }
                                return loading();
                              });
                            },
                          );
                  }
                  return loading();
                },
              ),
            ),
          ),

          // total amount + pay now

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // total price
                      Text(
                        'CHECKOUT',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // pay now
                  BlocBuilder<DetailTransactionBloc, DetailTransactionState>(
                      builder: (context, state) {
                    if (state is DetailTransactionLoaded) {
                      return state.data.results!.isEmpty
                          ? Text(
                              ':| Tidak ada item',
                              style: TextStyle(color: Colors.white),
                            )
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CheckoutPage()));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: const [
                                    Text(
                                      'Bayar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            );
                    }
                    return Text("nope");
                  })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  deleteItem(id) {
    var product_id = {"product_id": id.toString()};

    final astate = context.read<AuthBloc>().state;
    if (astate is AuthLoaded) {
      context.read<DetailTransactionBloc>().add(
          DeleteProductToDetailTransactionList(
              product_id, astate.userModel.token));
    }
  }
}
