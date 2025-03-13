# Why

Why would I want to use a Cartographer probe over the stock probing solution on the K2?

## Existing Problems

### Accuracy

In testing we've found that the prtouch_v3 (stock probe on the K2) has an error rate of about 0.01%.

While 0.01% may not seem like a frequent failure it is enough to both erode confidence and introduce anomolies.

### Detail

The original K2 firmware (1.0.x through 1.1.1.x) limited the bed meshes to _exactly_ 9x9.  With a 350x350 (actually 370x370) build plate, this meant the distance between probed points was: 42.5 (taken directly from the mesh)

With current firmware versions (1.1.2.6 as of this writing) the 9x9 mesh limitation has been removed and other sizes are supported.  However, even with the current firmware, the maximum mesh is 25x25, which means a distance of: 14.1667 mm (taken directly from the mesh)

So, at best, with the stock solution and a full bed mesh, you get a resolution detail of 14.2 mm.

### Speed

The prtouch_v3 (stock probe on the K2) physically touches each specific point on the bed.  This takes time.  As the size of the bed increases to maintain the same level of detail (space between points on the bed mesh) the number of points needs to be increased.  This in turn translates to longer and longer time to complete a bed mesh.

* 9x9 mesh using the prtouch takes: ~15 minutes
* 25x25 mesh using the prtouch takes: 35 minutes

Given that detailed probing takes so long, it became a common practice to perform a bed mesh probing and then save the results so they can be reused later.  In fact, this is precisely what the K2 does.

## The Solution

The Cartographer probe does not suffer from any of the above issues.
<!-- markdownlint-disable MD024 -->
### Accuracy

The Cartographer probe is widely used with no signs of accuracy issues being reported

### Detail

The Cartographer probe uses more traditional Klipper settings and allows you (the user) to specify the level of detail you want to achieve, even if that's 1mm between probed points.

### Speed

With the Cartographer a two pass (yes, two pass):

* 9x9 mesh takes: ~40 seconds
* 25x25 mesh takes: ~2 minutes
* 100x100[1] mesh takes: ~7 minutes

[1] - we don't advise this as it takes a long time for the klipper process to start on the K2, ~1 minute startup

<!-- markdownlint-enable MD024 -->

## Sounds too good to be true

You're right, it does sound too good to be true.

## What's the catch

The K2 doesn't (as of this writing) provide the necessary kernel module to natively support the Cartographer probe.  So, we've had to create a userspace solution for talking to the Cartographer probe.

The **TL;DR** of _kernel_ vs _user space_ is that our solution is a _bit hacky_ and _slower_ than it should be.

## What do I need?

### Right Angle Cartographer

For the current mount, you'll need a [Right Angle Cartographer](https://cartographer3d.com/products/cartographer-probe-v3-with-adxl345-right-angle-can-usb)

There are also [color options](https://cartographer3d.com/products/cartographer-v3-colour-edition), but be _sure_ you get the **Right Angle** variant.

### M2.6x20mm screws/bolts

Be sure to select the right size [**M2.6x20mm**](https://www.aliexpress.us/item/3256803144062450.html).

### Heat inserts

The printed mount requires 2x [M3x5x4 heat inserts](https://www.amazon.com/Threaded-Inserts-Soldering-Printed-Materials/dp/B0D7M3LJDL)

## How

See the [setup](./SETUP.md) instructions.
