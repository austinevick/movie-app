import 'package:bloc_pattern/blocs/crypto/crypto_bloc.dart';
import 'package:bloc_pattern/fade_in_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_color/random_color.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RandomColor randomColor = RandomColor();
  final _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Top Coins'),
        ),
        body: BlocBuilder<CryptoBloc, CryptoState>(builder: (context, state) {
          return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Colors.grey[900],
                  ],
                ),
              ),
              child: buildBody(state));
        }));
  }

  buildBody(CryptoState state) {
    if (state is CryptoLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(
            Theme.of(
              context,
            ).accentColor,
          ),
        ),
      );
    } else if (state is CryptoLoaded) {
      return RefreshIndicator(
        color: Theme.of(context).accentColor,
        onRefresh: () async {
          context.bloc<CryptoBloc>().add(RefreshCoins());
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) => onScrollNotification(
            notification,
            state,
          ),
          child: ListView.builder(
              controller: _scrollController,
              itemCount: state.coins.length,
              itemBuilder: (context, index) {
                final coin = state.coins[index];
                return FadeInAnimation(
                  delay: 5,
                  child: Card(
                    color: Colors.black,
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: randomColor.randomColor(
                              colorBrightness: ColorBrightness.dark,
                            ),
                            child: Text(
                              '${coin.fullName.substring(0, 1)}',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        coin.fullName,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        coin.name,
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        '\$${coin.price.toStringAsFixed(4)}',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      );
    } else if (state is CryptoError) {
      return Center(
        child: Text(
          'Error loading coins\n Please check your internet connection',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  onScrollNotification(ScrollNotification notification, CryptoLoaded state) {
    if (notification is ScrollEndNotification &&
        _scrollController.position.extentAfter == 0) {
      context.bloc<CryptoBloc>().add(LoadMoreCoins(coins: state.coins));
    }
    return false;
  }
}
