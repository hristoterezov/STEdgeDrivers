# Edge Driver for Aspire RF9500 battery operated switch

This driver receives the zwave messages and translates them into smartthings button events. The events can be used in automations in order to control other devices. Currently there are 3 buttons defined as capabilities - main, up, down. The up and down buttons are corresponding to the physical dimmer up and down buttons on the switch.

## Prerequisites

1. Set up the SmartThings CLI according to the [configuration document](https://github.com/SmartThingsCommunity/smartthings-cli/blob/master/packages/cli/doc/configuration.md).
2. A SmartThings hub with firmware version 000.038.000XX or greater.

## Uploading Your Driver to SmartThings

Take a look at the installation tutorial in the [Developer's Community](https://community.smartthings.com/t/creating-drivers-for-zwave-devices-with-smartthings-edge/229503).

## Onboarding your New Device

1. Open the SmartThings App and go to the location where the hub is installed.
2. Go to Add (+) > Device or select _Scan Nearby_ (If you have more than one, select the corresponding Hub as well)

3. Put your device in pairing mode; Press the main button a few times until the device is added.

## Additional Notes

1. This driver allows you to change 1 configuration parameters of the device.
2. When experimenting with Z-Wave devices, remember to exclude the device before re-pairing.
