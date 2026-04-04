# Requirements

- Stock list
    - Displays 25 symbols
    - Connects to a websocket and listens to the feed
    - Displays connection status
    - Displays start/stop button (connects and disconnects the feed)
    - Displays name, price and price change indicator (+-amount, color)
    - Sorts by name, price change
    - On selection of a symbol shows Stock details
- Stock details
    - Displays a title
    - Displays a price and an indicator
    - Listens to the feed
- Price updater
    - Periodically updates prices with random data
- Unit tests strategy


# Components

## AppDelegate
- Handles app startup cycle and state management
- Handles feature configuration using StockFeatureProvider mock

## StockFeatureProvider
- Simulates configuration of the app features

## RootCoordinator
- Handles top level navigation
- Handles and coordinates features

## StockProvider
- A source of data which has its status and connectivity functions.
- There are two implementations of the protocol:
    - StockProviderMock
      Provides random prices and generate updates using timers.
      
    - StockProviderWeb
      Provides random prices, connects to the Postman echo websocket
      service in order to implement network interaction. Generate
      updates using timer and post them into the websocket.


# Application and architecture

Due to app requirements for real-time updates from the websocket
and to avoid back pressure the following data flow model was selected:

## Data flow

CADisplayLink -> View model -> Diffable data source -> UI update

CADisplayLink requests a data from view model in order to update the UI
as smooth as possible (coordinated with screen refresh rate).

View model acts as a buffer storing the latest data in order to avoid a
back presure from the external data source.

View model handles the diffable data source in order to keep the actual
snapshot which is ready for the UI.

## Architecture

Application uses MVVM+C pattern where coordinators are responsible for
deep link handling and for presentation of features (UI components).


# Testing

Loose coupling with protocols allow to mock any dependency and to control
the desired behavior.

The following components are subjects for testing:

AppDIContainer
    - Services of the shared instance must not be resolved by AppDIContainer()
      instances and vice-versa.

RootCoordinator
    - Must resolve and request features from FeatureProvider.
    - Must correctly start and coordinate to the child coordinators.
    
StockListViewModel
    - Resolves a stock provider after configuration.
    - Translates stock providers status changes through stockProviderStatus var.
    - Reacts on start/stop calls and notifies its stock provider.
    - Reacts on sorting requests and passes the correct data from stock provider
      to the UI (table view and data source).
