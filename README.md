# Requirements

## Stock list

- Displays 25 symbols
- Connects to a websocket and listens to the feed
- Displays connection status
- Displays start/stop button (connects and disconnects the feed)
- Displays name, price and price change indicator (+-amount, color)
- Sorts by name, price change
- On selection of a symbol shows Stock details

## Stock details

- Displays a title
- Displays a price and an indicator
- Listens to the feed

## Price updater
- Periodically updates prices with random data

## Unit tests strategy


# Components

## AppDelegate
- Handles app startup cycle and state management
- Handles feature configuration using StockFeatureProvider mock

## StockFeatureProvider
- Simulates configuration of the app features

## RootCoordinator
- Handles top level navigation
- Handles and coordinates features

// TODO:
StockProviderMock
StockProviderWeb
StockDetails


# Application and architecture

Due to app requirements for real-time updates from the websocket
and to avoid back pressure the following data flow model was selected:
Websocket -> Buffer -> CADisplayLink -> Diffable data source


# Testing

// TODO
