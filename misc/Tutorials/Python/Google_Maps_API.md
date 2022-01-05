## Querying the Google Maps API from Python
###### Author: James Triveri


### Prerequisites

This tutorial requires the requests library. If you access Python using Anaconda, you're all set (requests is distributed along with Anaconda). Otherwise, open the command prompt (press Windows key + R. type "cmd" (no quotes) followed by ENTER) and type:

```cmd
C:\> python -m pip install requests
```

### Setup

The Google Maps Platform offers a number of Web Services for all things map related: End users can retrieve geographic coordinates from addresses, lookup an address from a geographic coordinate pair, retrieve elevation data, travel distance and time and directions in a programmatic way. In this article, I'll demonstrate how to query and retrieve various geographic data attributes using Google's Web Services API using the requests library. 
Note that in order to access the Google Web Services API, you need a Gmail account and an API key. Details on obtaining and API key are available [here](https://developers.google.com/maps/documentation/distance-matrix/get-api-key).


#### 1. Determine Latitude and Longitude from a Street Address

In the function that follows, `get_coords` takes for arguments the address as a string and the API key, and returns a dictionary with keys `"lat"` and `"lng"`:


```python
"""
Example 1: Getting lat + lng associated with an address.
"""
import re
import sys
import os
import requests

# Made up key. Use your own. 
KEY = "AAAAAAAA-bbbbbbbb-CCCCCCCCCCCCCCCCCC"


def get_coords(address, authkey):
    """
    Obtain geographic coordinates corresponding to address.

    address: str
        Tragte address as string.

    authkey: str
        Google Maps authorization keys as string.

    Returns
    -------
    dict
    """
    base_url = "https://maps.googleapis.com/maps/api/geocode/json?address="
    addr_str = re.sub("\s+", "+", address.strip())
    api_url = "{}{}&key={}".format(base_url, addr_str, authkey)
    response = requests.get(api_url).json()
    coords = response["results"][0]["geometry"]["location"]
    return({"lat":coords["lat"], "lng":coords["lng"]})
```

After reading `get_coords` into the current Python session, we can pass it any valid address and it will return the coordinates. For example, to obtain the coordinates for the Guide One office, run:

```python
In [2]: address = "1111 Ashworth Rd West Des Moines IA 50265"
In [3]: get_coords(address, KEY)
Out[3]: {'lat': 41.5855471, 'lng': -93.7194729}
```

This is very convenient, and can be used for a number of different applications. 



#### 2. Address Retrieval from Coordinate Pair

We can use the Google Maps API to go the other way: For a given lat-lon pair, we can obtain the associated address. 
`get_address` encapsulates this logic:

```python
"""
Example 2: Get address from lat-lng coordinate pair.
"""

def get_address(coords, authkey):
    """
    Reverse geocode lookup. For a given coordinate pair, return the
    associated address, or most proximate address to the location.

    Parameters
    ----------
    coords: list or tuple
        2-element sequence containing location latitude and longitude. 

    authkey: str
        Google Maps authorization keys as string.

    Returns
    -------
    str
    """
    base_url = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
    coords_str = ",".join(str(ii) for ii in coords)
    api_url = "{}{}&key={}".format(base_url, coords_str, authkey)
    response = requests.get(api_url).json()
    address = response["results"][0]["formatted_address"].strip()
    return(address)

```

Let's use the coordinates returned from `get_coords` to obtain the address of Guide One's home office:

```python
In [4]: get_address((41.5855471, -93.7194729), KEY)
Out[4]: '1111 Ashworth Rd, West Des Moines, IA 50265, USA'
```

#### 3. Determine Travel Distance Between Two Addresses

The Google Maps Distance Matrix API can be used to compute the distance between two addresses or sets coordinate pairs. Note that the distance will be the driving distance, not the air distance.  
Our next function, `get_distance`, takes two addresses `addr1` and `addr2`, along with `authkey`, and returns the total driving distance between locations: 

```python
"""
Example 3: Get driving distance between teo addresses. 
"""

def get_distance(addr1, addr2, authkey):
    """
    Compute driving distance between two addresses in kilometers.

    Parameters
    ----------
    addr1: str
        First address.

    addr2: str
        Second address.

    authkey: str
        Google Maps authorization keys as string.

    Returns
    -------
    float
    """
    base_url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric"
    addr_str1 = "&origins={}".format(re.sub("\s+", "+", addr1.strip()))
    addr_str2 = "&destinations={}".format(re.sub("\s+", "+", addr2.strip()))
    api_url  = "{}{}{}&key={}".format(base_url, addr_str1, addr_str2, authkey)
    response = requests.get(api_url).json()
    return(int(response["rows"][0]["elements"][0]["distance"]["value"]) / 1000)
  ```

  Let's find the driving distance between Grand Canyon National Park and Mt. Rushmore:


  ```python
In [5]: addr1 = "13000 SD-244, Keystone, SD 57751"
In [6]: addr2 = "Grand Canyon, AZ 86023"
In [7]: get_distance(addr1, addr2, KEY)
Out[7]: 1679.494
```
The result is in kilometers. To convert to miles, multiply 1679.494 by 0.621. From IPython, last output value can be recalled using the underscore, `_`:

```python
In [8]: _ * 0.621
Out[8]: 1043.589 # distance in miles
```


#### 4. Determine the Elevation of a Coordinate Pair


Our next function, `get_elevation`, accepts a pair of coordinates along with an API key and returns the elevation in meters:


```python
"""
Example 4: Retrieve elevation associated with provided address.
"""

def get_elevation(coords, authkey):
    """
    Return the elevation of the specified address in meters.

    Parameters
    ----------
    coords: tuple or list
        2-element sequence containing location latitude and longitude.

    authkey: str
        Google Maps authorization keys as string.

    Returns
    -------
    float
    """
    base_url = "https://maps.googleapis.com/maps/api/elevation/json?locations="
    coords_str = ",".join(str(ii) for ii in coords)
    api_url = "{}{}&key={}".format(base_url, coords_str, authkey)
    response = requests.get(api_url).json()
    elevation = response["results"][0]["elevation"]
    return(elevation)

```

Let's find the elevation of Denver, CO. We lookup a pair of coordinates associated with Denver, then call `get_elevation`:

```python
In [9]: coords = (39.7392, -104.9903)
In[10]: get_elevation(coords, KEY)
Out[10]: 1596.5810546875
In[11]: _ * 3.28084
Out[11]: 5238.126987460937
```

The result returned by `get_elevation` is in meters. To convert meters to feet we multiply the result by 3.28084, which yields an elevation of ~5238ft., roughly 1 mile.


#### 5. Obtain Driving Directions Between Two Locations


`get_directions` returns directions between two addresses, specified as `start` and `end`:

```python
"""
Example 5: Get directions from one location to another.
"""

def get_directions(start, end, authkey):
    """
    Generate directions from start location to end location.

    start: str
        Starting address as string.

    end: str
        Destination address as string.

    authkey: str
        Google Maps authorization keys as string.

    Returns
    -------
    dict
    """
    base_url = "https://maps.googleapis.com/maps/api/directions/json?"
    start_addr = re.sub("\s+", "+", start.strip())
    end_addr = re.sub("\s+", "+", end.strip())
    api_url = "{}origin={}&destination={}&key={}".format(base_url, start_addr, end_addr, authkey)
    response = requests.get(api_url).json()

     # Parse html instructions for plain-text display.
    stepslist = response["routes"][0]["legs"][0]["steps"]
    directions = [i["html_instructions"] for i in stepslist]
    directions = [re.sub(r"</?b>", "", i) for i in directions]
    directions = [re.sub(r"<div.*?>", " ", i) for i in directions]
    directions = [re.sub(r"</div>", "", i) for i in directions]
    directions = [re.sub(r"&nbsp;", "", i) for i in directions]
    return(directions)
```

Lets get driving directions from Guide One to the Field of Dreams movie site in Dyersville:


```python
In[12]: start = "1111 Ashworth Rd West Des Moines IA 50265"
In[13]: end = "28995 Lansing Road, Dyersville, IA 52040"
In[14]: get_directions(start, end, KEY)
Out[14]:
['Head east toward 11th St',
 'Turn right onto 11th St',
 'Turn left onto Ashworth Rd',
 'Turn left onto 8th St',
 'Turn left to merge onto I-235 E',
 'Continue onto I-35 N',
 'Take exit 142A to merge onto US-20 E toward Waterloo',
 'Continue onto I-380 S/<wbr/>US-20 E',
 'Keep left at the fork to continue on US-20 E',
 'Take exit 294 for IA-136 toward Dyersville/<wbr/>Cascade',
 "Turn left onto IA-136 N/<wbr/>9th St SE Continue to follow IA-136 N Pass by Casey's (on the left in 0.4mi)",
 'Turn right onto 12th St NE/<wbr/>3rd Ave NE',
 'Continue onto 5th Ave NE',
 'Continue onto Dyersville East Rd',
 'Turn right onto Lansing Rd',
 'Turn left onto Field of Dreams Way Destination will be on the right']
 ```


#### 6. Place a Pin on a Map


Our final example showcases `pin_address`, which takes a single argument, `addr`, representing the address to pin. Upon execution, a web browser will open rendering a map with a pin highlighting the specified location.


```python
"""
Example 6: Place a pin on a map at the specified location.
"""
import webbrowser

def pin_address(addr, authkey):
    """
    Set pin at addr. Upon execution, a browser will open, displaying a pin 
    on a map highlighting the specified address.

    Parameters
    ----------
    addr: str
        Target address as string.

    Returns
    -------
    None
    """
    base_url = "https://www.google.com/maps/search/?api=1&query="
    addr_str = re.sub("\s+", "+", loc.strip())
    api_url = "{}{}&key={}".format(base_url, addr_str, authkey)
    webbrowser.open(api_url, new=2)
```


Let's place a pin highlighting Guide One's home office at `1111 Ashworth Rd West Des Moines IA 50265`:

```python
In[15]: addr = "1111 Ashworth Rd West Des Moines IA 50265"
In[16]: pin_address(addr)
```


Upon execution, a browser will open rendering the pinned location:

![mapsapi0](https://git.guidehome.com/projects/AC/repos/tutorials/browse/Supporting/mapsapi0.png)

