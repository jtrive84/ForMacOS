## Computing the Distance Between Geographic Coordinate Pairs
###### Author: James Triveri


### References 

* Haversine formula: https://en.wikipedia.org/wiki/Haversine_formula
* GIS FAQ - Great Circle Distance: http://www.movable-type.co.uk/scripts/gis-faq-5.1.html


### Prerequisites

This tutorial requires the requests library. If you access Python using Anaconda, you're all set (requests is distributed along with Anaconda). Otherwise, open the command prompt (press Windows key + R. type "cmd" (no quotes) followed by ENTER) and type:

```cmd
C:\> python -m pip install requests
```

### Setup

It is frequently necessary to compute the distance between a pair of geographic coordinates, or the distance between multiple sets of coordinates and a central reference point. This can be readily accomplished by making use of the *haversine formula*, which determines the great-circle distance between two points on a sphere given their longitudes and latitudes. The Haversine formula is expressed as:

$$
d = 2r\arcsin \left({\sqrt {\sin^{2}\left({\frac{\varphi_{2}-
    \varphi_{1}}{2}}\right)+\cos(\varphi_{1})\cos(\varphi_{2})\sin^{2}
    \left({\frac{\lambda_{2}-\lambda_{1}}{2}}\right)}}\right)
$$

Where:

* $\phi_{1}$ represents the latitude of point 1.
* $\phi_{2}$ represents the latitude of point 2.
* $\lambda_{1}$ represents the longitude of point 1.
* $\lambda_{2}$ represents the longitude of point 2.

Geographic coordinates can be specified in various formats, but one common representation, and the format used for the remainder of the tutorial is the decimal degrees format (e.g., (41.8781N, 87.6298W) for Chicago, (19.4326N, 99.1332W) for Mexico City, etc.).

The Earth is not a perfect sphere, and as a result, the radius varies as a function of distance from the equator (the radius is 6357km at the poles and 6378km at the equator). Due to this variation, the haversine distance calculation will always contain some error, but for non-antipodal coordinates provides a good approximation. In the examples that follow, a constant Earth radius of 6367km is assumed. 

Typically, results from inverse trigonometric functions are expressed in radians. This is the case for the Python Standard Library’s inverse trigonometric functions, which can be verified by inspecting the docstring for `asin`:

```python
In [1]: import math
In [2]: math.asin?
Signature: math.asin(x, /)
Docstring: Return the arc sine (measured in radians) of x.
Type:      builtin_function_or_method
```
To express the result in decimal degrees, multiply the number of radians by  $180/\pi=57.295780$ degrees/radian.

We create a function that computes the distance between two coordinate pairs using the haversine formula. Coordinates should be passed in decimal format. Distance is returned in kilometers. As previously mentioned, we assume a constant Earth radius of 6357km:

```python
"""
Implementation of the haversine formula. 
"""
import math

def haverdist(coords1, coords2):
    """
    Compute distance between geographic coordinate pairs.

    Parameters
    ----------
    coords1: tuple or list;
        (lat1, lon1) of first geolocation.
    coords2: tuple or list
        (lat2, lon2) of second geolocation.

    Returns
    -------
    float
        Distance in kilometers between coords1 and coords2.
    """
    # Convert degrees to radians then compute differences.
    R = 6367 
    rlat1, rlon1 = [ii * math.pi / 180 for ii in coords1]
    rlat2, rlon2 = [ii * math.pi / 180 for ii in coords2]
    drlat, drlon = (rlat2 - rlat1), (rlon2 - rlon1)

    inner = (math.sin(drlat / 2.))**2 + (math.cos(rlat1)) * \
            (math.cos(rlat2)) * (math.sin(drlon /2.))**2
    return(2.0 * R * math.asin(min(1., math.sqrt(inner))))
```

To test `haverdist`, we estimate the distance between New York City and Chicago. For Chicago, latitude=41.881832 and longitude=-87.623177. For New York City, latitude=40.730610 and longitude=-73.935242. We load the function into memory then embed each latitude and longitude in separate coordinate pair tuples:


```python
In [3]: pair1 = (41.881832, -87.623177) # Chicago
In [4]: pair2 = (40.730610, -73.935242) # NYC
In [5]: haverdist(pair1, pair2)
Out[1]: 1148.514752233814
```

`haverdist` estimates the distance between Chicago and New York City to be 1149km (~713 miles). If we compare this to [Google Maps GeoDistance API](https://www.google.com/maps/dir/Chicago,+Illinois/New+York/@40.5678459,-89.7632974,5z/data=!3m1!4b1!4m13!4m12!1m5!1m1!1s0x880e2c3cd0f4cbed:0xafe0a6ad09c0c000!2m2!1d-87.6297982!2d41.8781136!1m5!1m1!1s0x89c24fa5d33f083b:0xc80b8f06e177fe62!2m2!1d-74.0059728!2d40.7127753) using the same set of coordinate pairs, we get 1,296km (~803 miles). The discrepancy is due to the nature of the measurement: The distance calculated with `haverdist` computes the shortest distance between the two pairs of geographic coordinates, or the "air travel" distance. The Google Maps API calculates the driving distance, which will be greater than or equal to the air travel distance.

Our measurement can be validated using [distancefromto.net](https://www.distancefromto.net/), which provides air distance estimates between explicitly named locations. Plugging in Chicago and New York City, we see that the air travel distance is 1144km (~711 miles), within 0.35% of our estimate.


### Speed Estimate of the International Space Station (ISS)

Using `haverdist` along with publicly available ISS location data, we can estimate the speed at which the International Space Station orbits the Earth. By querying the [Open Notify API](http://open-notify.org/Open-Notify-API/ISS-Location-Now/) using the requests library, we obtain a response encoded as follows:


```json
{
  "message": "success", 
  "timestamp": UNIX_TIME_STAMP, 
  "iss_position": {
    "latitude": CURRENT_LATITUDE, 
    "longitude": CURRENT_LONGITUDE
  }
}
```

The response is formatted as JSON (Javascript Object Notation), which is a popular data interchange format that uses human-readable text to store and transmit data objects consisting of attribute–value pairs and array data types. Due to it's readability, it has gradually replaced XML as the primary data interchange format for web-based applications.

Our approach entails taking two snapshots of the ISS's Earth-relative position separated by a known time differential. The velocity is then the distance between the two sets of coordinates (from haverdist) divided by the time differential: 

$$
v = \frac{d}{t},
$$

where $v$ is the speed, $d$ the distance traversed and $t$ the time elapsed between each measurement. According to the Open Notify website, polling should occur no more frequently than every 5 seconds. We'll a 5 second duration as the time differential in the speed calculation.

Next we define two additional functions: `getiss`, which returns the Open Notify json response with timestamped latitude and longitude of the ISS, and `getspeed`, which takes two coordinate pairs and returns the speed in km/s:


```python
"""
Compute the speed of ISS relative to the surface of the Earth. 
"""
import datetime
import math
import os
import sys
import time
import requests


def getiss():
    """
    Get timestamped geo-coordinates of International Space Station.

    Returns
    -------
    dict
        Dictionary with keys "latitude", "longitude" and 
        "timestamp" indicating time and position of ISS. 
    """
    dpos = dict()
    resp = requests.get("http://api.open-notify.org/iss-now.json").json()
    if resp["message"]!="success":
        raise RuntimeError("Unable to access Open Notify API.")
    dpos["timestamp"] = resp["timestamp"]
    dpos["latitude"]  = float(resp["iss_position"]["latitude"])
    dpos["longitude"] = float(resp["iss_position"]["longitude"])
    return(dpos)


def getspeed(dloc1, dloc2):
    """
    Compute speed of ISS relative to Earth's surface using a pair of coordinates 
    retrieved via `getiss`. 

    Parameters
    ----------
    dloc1: dict
        Dictionary with keys "latitude", "longitude" "timestamp"
        associated with the first positional snapshot.
    dloc2: dict
        Dictionary with keys "latitude", "longitude" "timestamp"
        associated with the second positional snapshot.

    Returns
    -------
    float
        Scalar value representing the average speed in km/s of the
        International Space Station relative to the Earth in translation 
        from `dloc1` to `dloc2`. 
    """
    # Convert unix epochs to timestamp datetime objects.
    ts1  = datetime.datetime.fromtimestamp(dloc1['timestamp'])
    ts2  = datetime.datetime.fromtimestamp(dloc2['timestamp'])
    secs = abs((ts2-ts1).total_seconds())
    loc1 = (dloc1["latitude"], dloc1["longitude"])
    loc2 = (dloc2["latitude"], dloc2["longitude"])
    dist = haverdist(loc1, loc2)
    return((dist / secs) * 3600)
```


Then, after loading the functions into the environment, from the IPython terminal, run:

```python
In [2]: dpos1 = getiss(); time.sleep(5); dpos2 = getiss()
In [3]: getspeed(dpos1, dpos2)
Out[2]: 26903.75803398553
```

According to our calculations, the average orbital speed of the ISS relative to Earth's surface was found to be ~27,000km/h (16,716 mph). Wikipedia's ISS page estimates the average orbital speed at 27,600km/h (17,100 mph), therefore the estimate using `haverdist` was off by only ~2.5%.
